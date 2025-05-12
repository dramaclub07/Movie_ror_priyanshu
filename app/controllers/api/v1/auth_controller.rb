# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[register login google refresh_token logout]
      skip_before_action :authenticate_user_from_token, only: %i[register login google refresh_token logout]

      def register
        user = User.new(user_params)
        if user.save
          tokens = generate_auth_tokens(user.id)
          store_auth_tokens(tokens, user)

          render json: {
            user: serialize_user(user),
            message: 'User registered successfully',
            auth_info: auth_info(tokens, include_tokens: true)
          }, status: :created
        else
          Rails.logger.error "User validation failed: #{user.errors.full_messages}"
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Registration error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def login
        user = User.find_by(email: params.dig(:user, :email))
        unless user
          Rails.logger.debug "User not found for email: #{params.dig(:user, :email)}"
          return render json: { error: 'Invalid credentials' }, status: :unauthorized
        end

        unless user.valid_password?(params.dig(:user, :password))
          Rails.logger.debug "Invalid password for user: #{user.email}"
          return render json: { error: 'Invalid credentials' }, status: :unauthorized
        end

        tokens = generate_auth_tokens(user.id)
        store_auth_tokens(tokens, user)

        render json: {
          user: serialize_user(user),
          message: 'User logged in successfully',
          auth_info: auth_info(tokens, include_tokens: true)
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Login error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def refresh_token
        refresh_token = cookies[:refresh_token]
        user = JwtService.verify_refresh_token(refresh_token)

        if user
          tokens = generate_auth_tokens(user.id)
          store_auth_tokens(tokens, user)

          render json: {
            message: 'Tokens refreshed successfully',
            auth_info: auth_info(tokens, include_tokens: true)
          }, status: :ok
        else
          clear_auth_cookies
          render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end
      rescue StandardError => e
        Rails.logger.error "Token refresh error: #{e.message}\n#{e.backtrace.join("\n")}"
        clear_auth_cookies
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def logout
        access_token = cookies[:access_token] || extract_token
        refresh_token = cookies[:refresh_token]
        JwtService.invalidate_tokens(current_user.id, access_token, refresh_token) if current_user && access_token
        clear_auth_cookies
        render json: {
          message: 'Successfully signed out',
          auth_info: {
            status: 'logged_out',
            tokens_cleared: true
          }
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Logout error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def google
        return render json: { error: 'Invalid Google token' }, status: :unauthorized if params[:access_token].blank?

        client = OAuth2::Client.new(
          ENV['GOOGLE_CLIENT_ID'],
          ENV['GOOGLE_CLIENT_SECRET'],
          authorize_url: 'https://accounts.google.com/o/oauth2/auth',
          token_url: 'https://accounts.google.com/o/oauth2/token'
        )

        access_token = OAuth2::AccessToken.new(client, params[:access_token])
        response = access_token.get('https://www.googleapis.com/oauth2/v3/userinfo')
        user_info = JSON.parse(response.body)

        user = User.from_omniauth(OpenStruct.new(
                                    provider: 'google_oauth2',
                                    uid: user_info['sub'],
                                    info: OpenStruct.new(
                                      email: user_info['email'],
                                      name: user_info['name']
                                    )
                                  ))

        if user.persisted?
          tokens = generate_auth_tokens(user.id)
          store_auth_tokens(tokens, user)

          render json: {
            user: serialize_user(user),
            message: 'Successfully authenticated with Google',
            auth_info: auth_info(tokens, include_tokens: true)
          }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue OAuth2::Error
        render json: { error: 'Invalid Google token' }, status: :unauthorized
      rescue StandardError => e
        Rails.logger.error "Google auth error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def profile
        render json: { user: serialize_user(current_user) }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Profile error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      def update_profile
        if current_user.update(user_params)
          render json: {
            user: serialize_user(current_user),
            message: 'Profile updated successfully'
          }, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Update profile error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Server error' }, status: :internal_server_error
      end

      private

      def auth_info(tokens, include_tokens: false)
        info = {
          status: 'authenticated',
          token_type: 'Bearer',
          access_token: {
            present: true,
            expires_in: (tokens[:access_token_expiry] - Time.now).to_i,
            expires_at: tokens[:access_token_expiry].to_i
          },
          refresh_token: {
            present: true,
            expires_in: (tokens[:refresh_token_expiry] - Time.now).to_i,
            expires_at: tokens[:refresh_token_expiry].to_i
          },
          cookie_info: {
            access_token_cookie: 'HTTP-only',
            refresh_token_cookie: 'HTTP-only',
            secure: Rails.env.production?,
            same_site: 'Strict'
          }
        }

        if include_tokens
          info[:access_token][:token] = tokens[:access_token]
          info[:refresh_token][:token] = tokens[:refresh_token]
        end

        info
      end

      def serialize_user(user)
        UserSerializer.new(user)
      end

      def generate_auth_tokens(user_id)
        JwtService.generate_tokens(user_id)
      end

      def store_auth_tokens(tokens, user)
        user.update!(refresh_token: tokens[:refresh_token])

        cookies[:access_token] = {
          value: tokens[:access_token],
          httponly: true,
          secure: Rails.env.production?,
          same_site: :strict,
          expires: tokens[:access_token_expiry],
          path: '/'
        }

        cookies[:refresh_token] = {
          value: tokens[:refresh_token],
          httponly: true,
          secure: Rails.env.production?,
          same_site: :strict,
          expires: tokens[:refresh_token_expiry],
          path: '/'
        }
      end

      def clear_auth_cookies
        cookies.delete(:access_token, path: '/')
        cookies.delete(:refresh_token, path: '/')
      end

      def extract_token
        request.headers['Authorization']&.split('Bearer ')&.last
      end

      def user_params
        permitted = %i[email password password_confirmation phone_number name]
        # Convert params to hash to avoid ActionController::Parameters issues
        params_hash = params.to_unsafe_h.with_indifferent_access
        Rails.logger.debug "Raw params: #{params_hash.inspect}"

        # Try params[:user] first, then params[:auth][:user]
        user_params = params_hash[:user] || params_hash.dig(:auth, :user)
        Rails.logger.debug "Extracted user params: #{user_params.inspect}"

        # Ensure user_params is a hash
        unless user_params.is_a?(Hash)
          Rails.logger.error "Invalid user params: #{user_params.inspect}"
          raise ActionController::ParameterMissing, 'user'
        end

        # Convert to ActionController::Parameters for permitting
        ActionController::Parameters.new(user_params).permit(*permitted)
      end
    end
  end
end
