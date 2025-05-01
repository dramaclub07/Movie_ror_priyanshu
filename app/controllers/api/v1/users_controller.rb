# Edit app/controllers/api/v1/users_controller.rb
# Add login action:
module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[create login phone_login forgot_password reset_password]

      def create
        user = User.new(user_params)
        if user.save
          tokens = JwtService.generate_tokens(user.id)
          user.update(refresh_token: tokens[:refresh_token])
          set_cookies(tokens)
          render json: { message: 'User created', user: user.slice(:id, :email, :name, :role), access_token: tokens[:access_token] },
                 status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
          tokens = JwtService.generate_tokens(user.id)
          user.update(refresh_token: tokens[:refresh_token])
          set_cookies(tokens)
          render json: { message: 'Login successful', user: user.slice(:id, :email, :name, :role), access_token: tokens[:access_token] },
                 status: :ok
        else
          render json: { errors: ['Invalid email or password'] }, status: :unauthorized
        end
      end

      def show
        render json: { user: @current_user.slice(:id, :email, :name, :role, :phone_number) }, status: :ok
      end

      def update
        if @current_user.update(user_params)
          render json: { message: 'User updated', user: @current_user.slice(:id, :email, :name, :role, :phone_number) },
                 status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @current_user.destroy
          render json: { message: 'User deleted' }, status: :ok
        else
          render json: { errors: ['Failed to delete user'] }, status: :unprocessable_entity
        end
      end

      def phone_login
        user = User.find_by(phone_number: params[:phone_number])
        if user && user.verify_otp(params[:otp])
          tokens = JwtService.generate_tokens(user.id)
          user.update(refresh_token: tokens[:refresh_token])
          set_cookies(tokens)
          user.send_email('Login OTP Verified', 'Your OTP was successfully verified for login.')
          render json: { message: 'Login successful', user: user.slice(:id, :email, :name, :role), access_token: tokens[:access_token] },
                 status: :ok
        else
          render json: { errors: ['Invalid phone number or OTP'] }, status: :unauthorized
        end
      end

      def update_password
        if @current_user.authenticate(params[:current_password])
          if @current_user.update(password: params[:new_password])
            render json: { message: 'Password updated' }, status: :ok
          else
            render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { errors: ['Current password is incorrect'] }, status: :unauthorized
        end
      end

      def forgot_password
        user = User.find_by(email: params[:email])
        if user
          otp = user.generate_otp
          user.send_email('Password Reset OTP', "Your OTP is #{otp}. It expires in 10 minutes.")
          render json: { message: 'OTP sent to your email' }, status: :ok
        else
          render json: { errors: ['Email not found'] }, status: :not_found
        end
      end

      def reset_password
        user = User.find_by(email: params[:email])
        if user && user.verify_otp(params[:otp])
          if user.update(password: params[:new_password])
            user.update(otp: nil, otp_expires_at: nil)
            user.send_email('Password Reset Successful', 'Your password has been reset successfully.')
            render json: { message: 'Password reset successful' }, status: :ok
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { errors: ['Invalid or expired OTP'] }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :phone_number, :role, :google_id, :github_id)
      end

      def set_cookies(tokens)
        JwtService.store_token_in_http_only_cookie(response.cookies, tokens[:access_token], :access_token)
        JwtService.store_token_in_http_only_cookie(response.cookies, tokens[:refresh_token], :refresh_token)
      end
    end
  end
end
