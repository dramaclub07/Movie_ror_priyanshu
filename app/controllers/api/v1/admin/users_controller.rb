module Api
  module V1
    module Admin
      class UsersController < ApplicationController
        before_action :authenticate_user!
        before_action :authorize_admin!
        before_action :set_user, only: %i[show update destroy]

        def index
          @users = User.all
          render json: @users
        end

        def show
          render json: @user
        end

        def update
          if @user.update(user_params)
            render json: @user
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @user.destroy
          head :no_content
        end

        private

        def set_user
          @user = User.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'User not found' }, status: :not_found
        end

        def user_params
          params.require(:user).permit(:name, :email, :phone_number, :role)
        end
      end
    end
  end
end
