module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[sign_up sign_in google refresh_token]
      before_action :authenticate_user_from_token, except: %i[sign_up sign_in google refresh_token sign_out]

      def sign_up
        user = User.new(user_params)
        if user.save
          tokens = generate_auth_tokens(user.id)
          store_auth_tokens(tokens, user)

          render json: {
            user: serialize_user(user),
            message: 'User created successfully',
            auth_info: auth_info(tokens, include_tokens: true)
          }, status: :created
        else
          Rails.logger.error "User validation failed: #{user.errors.full_messages}"
          render json: {
            errors: user.errors.full_messages,
            debug_info: {
              params: user_params.to_h,
              validation_errors: user.errors.details
            }
          }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Sign up error: #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: 'Registration failed' }, status: :internal_server_error
      end

      def sign_in
        user = User.find_by(email: params.dig(:user, :email) || params[:email])
        if user&.valid_password?(params.dig(:user, :password) || params[:password])
          tokens = generate_auth_tokens(user.id)
          store_auth_tokens(tokens, user)

          render json: {
            user: serialize_user(user),
            message: 'Logged in successfully',
            auth_info: auth_info(tokens, include_tokens: true)
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      rescue => e
        Rails.logger.error "Sign in error: #{e.message}"
        render json: { error: 'Login failed' }, status: :internal_server_error
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
          }
        else
          clear_auth_cookies
          render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end
      rescue => e
        Rails.logger.error "Token refresh error: #{e.message}"
        clear_auth_cookies
        render json: { error: 'Token refresh failed' }, status: :internal_server_error
      end

      def sign_out
        JwtService.invalidate_refresh_token(current_user.id) if current_user
        clear_auth_cookies
        render json: {
          message: 'Successfully signed out',
          auth_info: {
            status: 'logged_out',
            tokens_cleared: true
          }
        }
      rescue => e
        Rails.logger.error "Sign out error: #{e.message}"
        render json: { error: 'Sign out failed' }, status: :internal_server_error
      end

      def google
        return render json: { error: 'Access token is required' }, status: :unauthorized if params[:access_token].blank?

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

        tokens = generate_auth_tokens(user.id)
        store_auth_tokens(tokens, user)

        render json: {
          user: serialize_user(user),
          message: 'Successfully authenticated with Google',
          auth_info: auth_info(tokens, include_tokens: true)
        }
      rescue OAuth2::Error => e
        render json: { error: 'Invalid Google token' }, status: :unauthorized
      rescue => e
        Rails.logger.error "Google auth error: #{e.message}"
        render json: { error: 'Authentication failed' }, status: :internal_server_error
      end

      def profile
        render json: { user: serialize_user(current_user) }
      end

      def update_profile
        if current_user.update(user_params)
          render json: { user: serialize_user(current_user), message: 'Profile updated successfully' }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
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
        user.attributes.except('encrypted_password', 'refresh_token')
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

      def user_params
        permitted = %i[email password password_confirmation phone_number name]
        if params[:auth] && params[:auth][:user]
          params.require(:auth).require(:user).permit(*permitted)
        else
          params.require(:user).permit(*permitted)
        end
      end
    end
  end
end
