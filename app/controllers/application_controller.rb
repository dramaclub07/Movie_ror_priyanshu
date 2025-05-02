class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :authenticate_user!, except: [:frontend], unless: :admin_request?
  before_action :authenticate_user_from_token # For User (API)
  before_action :authenticate_admin_user_from_token # For AdminUser (ActiveAdmin)

  include Devise::Controllers::Helpers

  def frontend
    render file: Rails.root.join('public', 'index.html'), layout: false
  end

  private

  def json_request?
    request.format.json? || request.path.start_with?('/api/')
  end

  def admin_request?
    request.path.start_with?('/admin')
  end

  def authenticate_user!
    return if user_signed_in?

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def authenticate_admin_user!
    unless admin_user_signed_in?
      # Redirect to AdminUser sign-in page for HTML requests (ActiveAdmin)
      if request.format.html?
        redirect_to new_admin_user_session_path, alert: "You need to sign in or sign up before continuing."
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
      return
    end

    # Role-based authorization for admin routes
    unless current_admin_user&.admin? || current_admin_user&.supervisor?
      redirect_to root_path, alert: "Unauthorized access"
    end
  end

  def authenticate_user_from_token
    token = cookies[:access_token] || request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info "Token found (User): #{token.present?}"
    return unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      Rails.logger.info "Decoded token (User): #{decoded_token}"
      user_id = decoded_token['user_id']
      user = User.find_by(id: user_id)
      Rails.logger.info "Authenticated user from token: #{user&.id}, Role: #{user&.role}"
      sign_in(user, scope: :user) if user
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error (User): #{e.message}"
      nil
    end
  end

  def authenticate_admin_user_from_token
    # Skip if not accessing an admin route
    return unless admin_request?

    token = cookies[:admin_access_token] || request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info "Token found (AdminUser): #{token.present?}"
    return unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      Rails.logger.info "Decoded token (AdminUser): #{decoded_token}"
      admin_user_id = decoded_token['admin_user_id']
      admin_user = AdminUser.find_by(id: admin_user_id)
      Rails.logger.info "Authenticated admin user from token: #{admin_user&.id}, Role: #{admin_user&.role}"
      sign_in(admin_user, scope: :admin_user) if admin_user
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error (AdminUser): #{e.message}"
      nil
    end
  end

  def clear_auth_cookies
    cookies.delete(:access_token, path: '/')
    cookies.delete(:refresh_token, path: '/')
    cookies.delete(:admin_access_token, path: '/')
  end
end