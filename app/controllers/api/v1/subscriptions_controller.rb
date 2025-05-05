class Api::V1::SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:success, :cancel]
  skip_before_action :verify_authenticity_token

  PLAN_TYPE_OPTIONS = %w[basic premium].freeze

  # POST /api/v1/subscriptions
  def create
    plan_type = params[:plan_type]

    # Validate the provided plan type
    return render_invalid_plan_type unless valid_plan_type?(plan_type)

    # Check if user already has an active subscription
    return render_active_subscription_error if active_subscription_exists?

    # Create the subscription and initiate Stripe checkout session
    subscription = create_subscription(plan_type)
    session = initiate_stripe_checkout(subscription, plan_type)

    # Return the session details for Stripe
    render json: { session_id: session.id, url: session.url }, status: :ok
  end

  # GET /api/v1/subscriptions/success
  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    subscription = find_subscription_by_stripe_customer(session.customer)

    if subscription
      finalize_subscription(subscription, session)
      render json: { message: 'Subscription updated successfully' }, status: :ok
    else
      render json: { error: 'Subscription not found' }, status: :not_found
    end
  end

  # GET /api/v1/subscriptions/cancel
  def cancel
    render json: { message: 'Payment cancelled' }, status: :ok
  end

  # GET /api/v1/subscriptions
  def index
    render json: { subscriptions: current_user.subscriptions }, status: :ok
  end

  # GET /api/v1/subscriptions/:id
  def show
    subscription = current_user.subscriptions.find_by(id: params[:id])

    if subscription
      render json: { subscription: subscription }, status: :ok
    else
      render json: { error: 'Subscription not found' }, status: :not_found
    end
  end

  # GET /api/v1/subscriptions/active
  def active
    subscription = current_user.subscriptions.find_by(status: 'active')

    if subscription
      render json: subscription_details(subscription), status: :ok
    else
      render json: { message: 'No active subscription found' }, status: :not_found
    end
  end

  private

  # Check if the plan type is valid
  def valid_plan_type?(plan_type)
    PLAN_TYPE_OPTIONS.include?(plan_type)
  end

  # Return invalid plan type error
  def render_invalid_plan_type
    render json: { error: 'Invalid plan type. Choose basic or premium.' }, status: :bad_request
  end

  # Check if the user already has an active subscription
  def active_subscription_exists?
    current_user.subscriptions.exists?(status: 'active')
  end

  # Render error if the user already has an active subscription
  def render_active_subscription_error
    render json: { error: 'You already have an active subscription.' }, status: :unprocessable_entity
  end

  # Create a new subscription
  def create_subscription(plan_type)
    start_date = Date.today
    end_date = start_date + 30.days

    # Set the subscription status to 'pending' initially
    current_user.subscriptions.create!(
      plan_type: plan_type,
      status: 'pending',
      start_date: start_date,
      end_date: end_date
    )
  end

  # Initiate the Stripe checkout session
  def initiate_stripe_checkout(subscription, plan_type)
    price_id = fetch_price_id(plan_type)
    customer_id = find_or_create_stripe_customer(subscription)

    Stripe::Checkout::Session.create(
      customer: customer_id,
      payment_method_types: ['card'],
      line_items: [{
        price: price_id,
        quantity: 1
      }],
      mode: 'subscription',
      metadata: { subscription_id: subscription.id, plan_type: plan_type },
      success_url: success_url(subscription),
      cancel_url: cancel_url
    )
  end

  # Fetch the Stripe price ID based on the plan type
  def fetch_price_id(plan_type)
    case plan_type
    when 'basic'
      'price_1RJzzhPwmKg08vVsikRVrObY' # Replace with actual price ID for basic plan
    when 'premium'
      'price_1RK00OPwmKg08vVsRalzKgtr' # Replace with actual price ID for premium plan
    end
  end

  # Success URL after Stripe checkout
  def success_url(subscription)
    "http://localhost:3000/api/v1/subscriptions/success?session_id={CHECKOUT_SESSION_ID}"
  end

  # Cancel URL if the user cancels the payment
  def cancel_url
    "http://localhost:3000/api/v1/subscriptions/cancel"
  end

  # Find or create a Stripe customer for the user
  def find_or_create_stripe_customer(subscription)
    if subscription.stripe_customer_id.nil?
      customer = Stripe::Customer.create(email: current_user.email)
      subscription.update(stripe_customer_id: customer.id)
      customer.id
    else
      subscription.stripe_customer_id
    end
  end

  # Find a subscription by the Stripe customer ID
  def find_subscription_by_stripe_customer(customer_id)
    Subscription.find_by(stripe_customer_id: customer_id)
  end

  # Finalize the subscription after Stripe checkout success
  def finalize_subscription(subscription, session)
    stripe_subscription = Stripe::Subscription.retrieve(session.subscription)

    # Update the subscription to 'active' once the user successfully completes checkout
    subscription.update!(
      stripe_subscription_id: session.subscription,
      status: 'active',
      start_date: Time.at(stripe_subscription.start_date).to_date,
      end_date: Time.at(stripe_subscription.current_period_end).to_date
    )
  end

  # Subscription details to send as JSON response
  def subscription_details(subscription)
    {
      plan_type: subscription.plan_type,
      start_date: subscription.start_date,
      end_date: subscription.end_date,
      stripe_subscription_id: subscription.stripe_subscription_id,
      status: subscription.status
    }
  end
end
