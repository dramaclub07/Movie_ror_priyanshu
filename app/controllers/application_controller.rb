# class ApplicationController < ActionController::Base
#   protect_from_forgery with: :null_session
#   skip_before_action :verify_authenticity_token, if: :json_request?
#   before_action :authenticate_user_from_token # For User (API)
#   before_action :authenticate_admin_user_from_token # For AdminUser (ActiveAdmin)
#   before_action :authenticate_user!, unless: -> { admin_request? || request.path == '/frontend' }


#   include Devise::Controllers::Helpers

#   def frontend
#     render file: Rails.root.join('public', 'index.html'), layout: false
#   end

#   def user_signed_in?
#     current_user.present?
#   end

#   def jwt_secret_key
#     ENV['JWT_SECRET_KEY'] || Rails.application.credentials.jwt_secret_key
#   end

#   def current_user
#     @current_user
#   end


#   private

#   def json_request?
#     request.format.json? || request.path.start_with?('/api/')
#   end

#   def admin_request?
#     request.path.start_with?('/admin')
#   end

#   def authenticate_user!
#     return if user_signed_in?
#     authenticate_user_from_token
#     unless @current_user
#       render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
#   end
# end

#   def authenticate_admin_user!
#     unless admin_user_signed_in?
#       # Redirect to AdminUser sign-in page for HTML requests (ActiveAdmin)
#       if request.format.html?
#         redirect_to new_admin_user_session_path, alert: "You need to sign in or sign up before continuing."
#       else
#         render json: { error: 'Unauthorized' }, status: :unauthorized
#       end
#       return
#     end

#     # Role-based authorization for admin routes
#     unless current_admin_user&.admin? || current_admin_user&.supervisor?
#       redirect_to root_path, alert: "Unauthorized access"
#     end
#   end

#   def authenticate_user_from_token
#     token = cookies[:access_token] || request.headers['Authorization']&.split(' ')&.last
#     Rails.logger.info "Token found (User): #{token.present?}"
#     return unless token

#     begin
#       decoded_token = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
#       Rails.logger.info "JWT Secret Present?: #{Rails.application.secret_key_base.present?}"
#       Rails.logger.info "Decoded token (User): #{decoded_token}"
#       current_user = User.find_by(id: decoded_token['user_id'])
#       Rails.logger.info "Authenticated user from token: #{user&.id}, Role: #{user&.role}"
#       if user
#         @current_user = user
#         sign_in(user, scope: :user)
#       end 
#     rescue JWT::DecodeError => e
#       Rails.logger.error "JWT Decode Error (User): #{e.message}"
#       nil
#     end
#   end

#   def authenticate_admin_user_from_token
#     # Skip if not accessing an admin route
#     return unless admin_request?

#     token = cookies[:admin_access_token] || request.headers['Authorization']&.split(' ')&.last
#     Rails.logger.info "Token found (AdminUser): #{token.present?}"
#     return unless token

#     begin
#       decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
#       Rails.logger.info "Decoded token (AdminUser): #{decoded_token}"
#       admin_user_id = decoded_token['admin_user_id']
#       admin_user = AdminUser.find_by(id: admin_user_id)
#       Rails.logger.info "Authenticated admin user from token: #{admin_user&.id}, Role: #{admin_user&.role}"
#       sign_in(admin_user, scope: :admin_user) if admin_user
#     rescue JWT::DecodeError => e
#       Rails.logger.error "JWT Decode Error (AdminUser): #{e.message}"
#       nil
#     end
#   end

#   def clear_auth_cookies
#     cookies.delete(:access_token, path: '/')
#     cookies.delete(:refresh_token, path: '/')
#     cookies.delete(:admin_access_token, path: '/')
#   end
# end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :authenticate_user_from_token # For User (API)
  before_action :authenticate_admin_user_from_token # For AdminUser (ActiveAdmin)
  before_action :authenticate_user!, unless: -> { admin_request? || request.path == '/frontend' }

  include Devise::Controllers::Helpers

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

  ## 🔐 Secret Key Helper (ENV first, fallback to credentials)
  def jwt_secret_key
    ENV['JWT_SECRET_KEY'] || Rails.application.credentials.jwt_secret_key
  end

  ## 📦 Request Type Checkers
  def json_request?
    request.format.json? || request.path.start_with?('/api/')
  end

  def admin_request?
    request.path.start_with?('/admin')
  end

  ## 🔐 User Authenticator
  def authenticate_user!
    return if user_signed_in?

    authenticate_user_from_token
    unless @current_user
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
    end
  end

  ## 🔐 Admin Authenticator
  def authenticate_admin_user!
    unless admin_user_signed_in?
      if request.format.html?
        redirect_to new_admin_user_session_path, alert: "You need to sign in or sign up before continuing."
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
      return
    end

    unless current_admin_user&.admin? || current_admin_user&.supervisor?
      redirect_to root_path, alert: "Unauthorized access"
    end
  end

  ## 🔑 Token Auth (User)
  def authenticate_user_from_token
    token = cookies[:access_token] || request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info "Token found (User): #{token.present?}"

    return unless token

    if jwt_secret_key.blank?
      Rails.logger.error "JWT secret key is missing for decoding"
      return
    end

    begin
      decoded_token = JWT.decode(token, jwt_secret_key, true, algorithm: 'HS256')[0]
      Rails.logger.info "Decoded token (User): #{decoded_token}"

      user = User.find_by(id: decoded_token['user_id'])
      Rails.logger.info "Authenticated user from token: #{user&.id}, Role: #{user&.role}"

      if user
        @current_user = user
        sign_in(user, scope: :user)
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error (User): #{e.message}"
    end
  end

  ## 🔑 Token Auth (AdminUser)
  def authenticate_admin_user_from_token
    return unless admin_request?

    token = cookies[:admin_access_token] || request.headers['Authorization']&.split(' ')&.last
    Rails.logger.info "Token found (AdminUser): #{token.present?}"

    return unless token

    if jwt_secret_key.blank?
      Rails.logger.error "JWT secret key is missing for admin decoding"
      return
    end

    begin
      decoded_token = JWT.decode(token, jwt_secret_key, true, algorithm: 'HS256')[0]
      Rails.logger.info "Decoded token (AdminUser): #{decoded_token}"

      admin_user = AdminUser.find_by(id: decoded_token['admin_user_id'])
      Rails.logger.info "Authenticated admin user from token: #{admin_user&.id}, Role: #{admin_user&.role}"

      sign_in(admin_user, scope: :admin_user) if admin_user
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error (AdminUser): #{e.message}"
    end
  end

  ## 🧹 Clear All Auth Tokens
  def clear_auth_cookies
    cookies.delete(:access_token, path: '/')
    cookies.delete(:refresh_token, path: '/')
    cookies.delete(:admin_access_token, path: '/')
  end
end
