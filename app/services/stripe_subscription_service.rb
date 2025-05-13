module StripeSubscriptionService
  PLANS = {
    basic: { price: nil, interval: nil },
    premium: { price: Rails.application.credentials.stripe[:price_premium], interval: 'month' }
  }.freeze

  Result = Struct.new(:success?, :session, :subscription, :error, keyword_init: true)

  def self.create_checkout_session(user:, plan:)
    Rails.logger.info "Creating checkout session for user: #{user.id}, plan: #{plan}"
    return Result.new(success?: false, error: 'Invalid plan') unless PLANS.key?(plan.to_sym)

    return Result.new(success?: false, error: 'Active subscription exists') if user.subscriptions.active.exists?

    subscription = user.subscriptions.create!(plan_type: plan, status: 'pending', start_date: Date.today)
    return activate_basic_subscription(subscription) if plan.to_sym == :basic

    create_stripe_session(user, subscription, plan)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe Error: #{e.message}\n#{e.backtrace.join("\n")}")
    subscription.destroy if subscription&.persisted?
    Result.new(success?: false, error: "Stripe operation failed: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Unexpected Error: #{e.message}\n#{e.backtrace.join("\n")}")
    subscription.destroy if subscription&.persisted?
    Result.new(success?: false, error: "Unexpected error: #{e.message}")
  end

  def self.create_stripe_session(user, subscription, plan)
    customer = create_or_retrieve_customer(user)
    base_url = Rails.env.development? ? 'http://localhost:5173' : 'http://localhost:5173'
    Rails.logger.info "Creating Stripe session with price: #{PLANS[plan.to_sym][:price]}, base_url: #{base_url}"
    session = Stripe::Checkout::Session.create(
      {
        customer: customer.id,
        payment_method_types: ['card'],
        line_items: [{
          price: PLANS[plan.to_sym][:price],
          quantity: 1
        }],
        mode: 'subscription',
        success_url: "#{base_url}/payment/success?session_id={CHECKOUT_SESSION_ID}&plan=#{plan}",
        cancel_url: "#{base_url}/payment/cancel?session_id={CHECKOUT_SESSION_ID}",
        metadata: { subscription_id: subscription.id }
      },
      { idempotency_key: "checkout-session-#{user.id}-#{subscription.id}-#{Time.now.to_i}" }
    )
    Result.new(success?: true, session: session, subscription: subscription)
  end

  def self.create_or_retrieve_customer(user)
    if user.stripe_customer_id
      Stripe::Customer.retrieve(user.stripe_customer_id)
    else
      customer = Stripe::Customer.create(email: user.email, name: user.name)
      user.update!(stripe_customer_id: customer.id)
      customer
    end
  end

  def self.activate_basic_subscription(subscription)
    subscription.update!(status: 'active')
    Result.new(success?: true, subscription: subscription)
  end

  def self.complete_subscription(session_id:)
    session = Stripe::Checkout::Session.retrieve(session_id)
    subscription = Subscription.find_by(id: session.metadata.subscription_id)
    return Result.new(success?: false, error: 'Subscription not found') unless subscription

    subscription.update!(
      status: 'active',
      stripe_subscription_id: session.subscription
    )
    Result.new(success?: true, subscription: subscription)
  end
end
