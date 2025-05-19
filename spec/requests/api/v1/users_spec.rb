require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  path '/api/v1/users/profile' do
    get 'Get user profile' do
      tags 'Users'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'profile found' do
        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get '/api/v1/users/profile', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        run_test! do
          get '/api/v1/users/profile', headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    put 'Update user profile' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          phone_number: { type: :string },
          current_password: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        }
      }

      response '200', 'profile updated' do
        let(:user_params) { { phone_number: '1234567890' } }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put '/api/v1/users/profile', headers: headers, params: { user: user_params }
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:user_params) { { phone_number: '1234567890' } }

        run_test! do
          put '/api/v1/users/profile', headers: headers, params: { user: user_params }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '422', 'invalid request' do
        let(:user_params) { { phone_number: '' } }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put '/api/v1/users/profile', headers: headers, params: { user: user_params }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path '/api/v1/users/notifications/settings' do
    get 'Get notification settings' do
      tags 'Users'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'settings found' do
        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get '/api/v1/users/notifications/settings', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        run_test! do
          get '/api/v1/users/notifications/settings', headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    put 'Update notification settings' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :settings, in: :body, schema: {
        type: :object,
        properties: {
          email_notifications: { type: :boolean },
          push_notifications: { type: :boolean },
          sms_notifications: { type: :boolean }
        }
      }

      response '200', 'settings updated' do
        let(:settings) { { email_notifications: true, push_notifications: false, sms_notifications: true } }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put '/api/v1/users/notifications/settings', headers: headers, params: { settings: settings }
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:settings) { { email_notifications: true } }

        run_test! do
          put '/api/v1/users/notifications/settings', headers: headers, params: { settings: settings }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '422', 'invalid request' do
        let(:settings) { { email_notifications: nil } }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put '/api/v1/users/notifications/settings', headers: headers, params: { settings: settings }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end