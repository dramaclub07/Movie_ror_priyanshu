class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: :json_request?

  include Devise::Controllers::Helpers

  before_action :authenticate_user_from_token, if: :api_request?
  
  before_action :authenticate_user!, unless: -> { admin_request? || request.path == '/frontend' || user_signed_in? }

  def frontend
    render file: Rails.root.join('public', 'index.html'), layout: false
  end

  def user_signed_in?
    current_user.present?
  end

  def current_user
    @current_user
  end

  private

  def jwt_secret_key
    ENV['JWT_SECRET_KEY'] || Rails.application.credentials.jwt_secret_key
  end

  def json_request?
    request.format.json? || request.path.start_with?('/api/')
  end

  def api_request?
    request.path.start_with?('/api/')
  end

  def admin_request?
    request.path.start_with?('/admin')
  end

  def authenticate_user!
    return if user_signed_in?

    render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
  end

  def authenticate_user_from_token
    token = extract_token
    return unless token

    begin
      payload = JwtService.decode(token)
      user_id = payload[:user_id] || payload['user_id']
      user = User.find_by(id: user_id)

      if user
        @current_user = user
        sign_in(:user, user, store: false) 
      else
        raise ActiveRecord::RecordNotFound, "User not found"
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue => e
      Rails.logger.error "Authentication Error: #{e.message}"
      render json: { error: 'Authentication failed' }, status: :unauthorized
    end
  end

  def extract_token
    auth_header = request.headers['Authorization']
    return auth_header.split(' ').last if auth_header.present? && auth_header.start_with?('Bearer ')

    cookies[:access_token] 
  end

  def clear_auth_cookies
    cookies.delete(:access_token, path: '/')
    cookies.delete(:refresh_token, path: '/')
    cookies.delete(:admin_access_token, path: '/')
  end
end
