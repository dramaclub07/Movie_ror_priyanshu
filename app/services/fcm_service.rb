# frozen_string_literal: true

require 'httparty'
require 'googleauth'

class FcmService
  def initialize
    @credentials = Rails.application.credentials.firebase # Changed from .fcm to .firebase
    raise 'FCM credentials not found in credentials.yml' unless @credentials

    # Create a temporary JSON file for Google Auth
    temp_json_file = Tempfile.new('fcm_service_account.json')
    temp_json_file.write(@credentials.to_json)
    temp_json_file.rewind

    # Initialize Google Auth credentials
    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: temp_json_file,
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    )

    # Clean up temp file
    temp_json_file.close
    temp_json_file.unlink

    raise 'Failed to initialize Google Auth credentials' if @authorizer.nil?
  end

  def send_notification(device_tokens, title, body, data = {})
    # Normalize and filter device tokens
    tokens = Array(device_tokens).map(&:to_s).reject do |token|
      token.strip.empty? || token.match?(/test/i)
    end

    return { status: :ok, message: 'No valid device tokens' } if tokens.empty?

    # Fetch OAuth2 access token
    access_token = @authorizer.fetch_access_token!['access_token']
    raise 'Failed to fetch OAuth2 access token' if access_token.nil? || access_token.empty?

    # FCM HTTP v1 API endpoint
    url = "https://fcm.googleapis.com/v1/projects/#{@credentials[:project_id]}/messages:send"

    # Headers
    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }

    # Send notifications to each token
    responses = tokens.map do |token|
      payload = {
        message: {
          token: token,
          notification: {
            title: title.to_s,
            body: body.to_s
          },
          data: data.transform_values(&:to_s)
        }
      }

      begin
        response = HTTParty.post(
          url,
          body: payload.to_json,
          headers: headers,
          timeout: 10
        )

        Rails.logger.info "FCM sent to #{token[0..20]}...: #{response.code} #{response.body}"
        { token: token, status_code: response.code, body: response.body }
      rescue StandardError => e
        Rails.logger.error "FCM error for #{token[0..20]}...: #{e.message}"
        { token: token, status_code: 500, body: e.message }
      end
    end

    # Determine overall status
    failed = responses.reject { |r| r[:status_code] == 200 }
    status = failed.empty? ? :ok : :error
    message = failed.empty? ? 'All notifications sent successfully' : "#{failed.count} notifications failed"

    {
      status: status,
      message: message,
      responses: responses
    }
  end
end
