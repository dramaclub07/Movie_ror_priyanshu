module Api
  module V1
    class SubscriptionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_subscription, only: %i[show update destroy]

      # GET /api/v1/subscriptions
      def index
        @subscriptions = current_user.subscriptions
        render json: @subscriptions
      end

      def active
        @subscription = current_user.subscriptions.active.first
        if @subscription
          render json: @subscription
        else
          render json: { error: 'No active subscription found' }, status: :not_found
        end
      end

      def history
        @subscriptions = current_user.subscriptions.order(created_at: :desc)
        render json: @subscriptions
      end

      # GET /api/v1/subscriptions/:id
      def show
        render json: @subscription.as_json(include: { movie: { include: :genre } })
      end

      # POST /api/v1/subscriptions
      def create
        @subscription = current_user.subscriptions.new(subscription_params)
        if @subscription.save
          render json: @subscription, status: :created
        else
          render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/subscriptions/:id
      def update
        if @subscription.update(subscription_params)
          render json: @subscription.as_json(include: { movie: { include: :genre } })
        else
          render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/subscriptions/:id
      def destroy
        @subscription.destroy
        head :no_content
      end

      private

      def set_subscription
        @subscription = current_user.subscriptions.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Subscription not found' }, status: :not_found
      end

      def subscription_params
        params.require(:subscription).permit(:movie_id, :plan_type, :status, :start_date, :end_date)
      end
    end
  end
end
