module Api
  module V1
    class SubscriptionsController < ApplicationController
      before_action :authenticate_user!, except: %i[success cancel]
      before_action :set_stripe_api_key
      skip_before_action :verify_authenticity_token

      def create
        result = StripeSubscriptionService.create_checkout_session(user: current_user, plan: params[:plan_type])
        if result.success?
          render json: {
            session_id: result.session&.id,
            url: result.session&.url,
            subscription: ActiveModelSerializers::SerializableResource.new(result.subscription,
                                                                           serializer: SubscriptionSerializer)
          }, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      def success
        result = StripeSubscriptionService.complete_subscription(session_id: params[:session_id])
        if result.success?
          render json: {
            message: 'Subscription activated',
            subscription: ActiveModelSerializers::SerializableResource.new(result.subscription,
                                                                           serializer: SubscriptionSerializer)
          }, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      def cancel
        render json: { message: 'Payment cancelled' }, status: :ok
      end

      def index
        subscriptions = current_user.subscriptions
        render json: {
          subscriptions: ActiveModelSerializers::SerializableResource.new(subscriptions, each_serializer: SubscriptionSerializer)
        }, status: :ok
      end

      def show
        subscription = current_user.subscriptions.find_by(id: params[:id])
        if subscription
          render json: {
            subscription: ActiveModelSerializers::SerializableResource.new(subscription, serializer: SubscriptionSerializer)
          }, status: :ok
        else
          render json: { error: 'Subscription not found' }, status: :not_found
        end
      end

      def active
        subscription = current_user.subscriptions.active.first
        if subscription
          render json: {
            subscription: ActiveModelSerializers::SerializableResource.new(subscription, serializer: SubscriptionSerializer)
          }, status: :ok
        else
          render json: { message: 'No active subscription' }, status: :not_found
        end
      end

      private

      def set_stripe_api_key
        Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
        return if Stripe.api_key

        render json: { error: 'Stripe API key missing' }, status: :internal_server_error
      end
    end
  end
end
