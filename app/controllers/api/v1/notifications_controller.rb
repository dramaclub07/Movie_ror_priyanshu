module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      def update_device_token
        if params[:device_token].blank?
          return render json: { error: 'Device token is required' }, status: :unprocessable_entity
        end

        current_user.update(device_token: params[:device_token])
        render json: { message: 'Device token updated successfully' }, status: :ok
      end

      def toggle_notifications
        current_user.update(notifications_enabled: !current_user.notifications_enabled)
        render json: {
          message: "Notifications #{current_user.notifications_enabled ? 'enabled' : 'disabled'}",
          notifications_enabled: current_user.notifications_enabled
        }, status: :ok
      end

      def test_notification
        unless current_user.device_token.present?
          return render json: { error: 'No device token registered' }, status: :unprocessable_entity
        end

        begin
          fcm_service = FcmService.new
          result = fcm_service.send_notification(
            current_user.device_token,
            'Test Notification',
            'This is a test notification from Movie Explorer!',
            { test: 'true' }
          )

          if result[:status] == :ok
            render json: { message: 'Test notification sent successfully' }, status: :ok
          else
            Rails.logger.error "Test notification failed: #{result[:message]}"
            render json: { error: 'Failed to send test notification', details: result[:message] },
                   status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error "Test notification error: #{e.message}"
          render json: { error: 'Failed to send test notification', details: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
