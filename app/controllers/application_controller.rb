class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :authenticate_user!, except: [:frontend]

  def frontend
    render file: Rails.root.join('public', 'index.html'), layout: false
  end

  private

  def json_request?
    request.format.json? || request.path.start_with?('/api/')
  end

  def authenticate_user!
    return if current_user

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    return @current_user if defined?(@current_user)

    # Try to get token from Authorization header
    auth_header = request.headers['Authorization']
    if auth_header && auth_header.start_with?('Bearer ')
      token = auth_header.split(' ').last
      begin
        decoded = JwtService.decode(token)
        @current_user = User.find_by(id: decoded[:user_id]) if decoded
      rescue JWT::DecodeError
        nil
      end
    end

    @current_user
  end

  def clear_auth_cookies
    cookies.delete(:access_token, path: '/')
    cookies.delete(:refresh_token, path: '/')
  end
end
