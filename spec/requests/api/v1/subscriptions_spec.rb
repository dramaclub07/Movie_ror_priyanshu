 require 'swagger_helper'

RSpec.describe 'api/v1/subscriptions', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  path '/api/v1/subscriptions' do
    get 'Lists user subscriptions' do
      tags 'Subscriptions'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'subscriptions found' do
        let!(:subscription) { create(:subscription, user: user) }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get '/api/v1/subscriptions', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        run_test! do
          get '/api/v1/subscriptions', headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    post 'Creates a subscription' do
      tags 'Subscriptions'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          plan_type: { type: :string, enum: %w[basic premium] },
          status: { type: :string, enum: %w[active inactive] }
        },
        required: %w[plan_type status]
      }

      response '201', 'subscription created' do
        let(:subscription_params) { { plan_type: 'basic', status: 'active' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          post '/api/v1/subscriptions', headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:created)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:subscription_params) { { plan_type: 'basic', status: 'active' } }

        run_test! do
          post '/api/v1/subscriptions', headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '422', 'invalid request' do
        let(:subscription_params) { { plan_type: 'invalid', status: 'active' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          post '/api/v1/subscriptions', headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true
    let(:subscription) { create(:subscription, user: user) }
    let(:id) { subscription.id }

    get 'Retrieves a subscription' do
      tags 'Subscriptions'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'subscription found' do
        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        run_test! do
          get "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'subscription not found' do
        let(:id) { 9999 }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    put 'Updates a subscription' do
      tags 'Subscriptions'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :subscription, in :body, schema: {
        type: :object,
        properties: {
          plan_type: { type: :string, enum: %w[basic premium] },
          status: { type: :string, enum: %w[active inactive] }
        }
      }

      response '200', 'subscription updated' do
        let(:subscription_params) { { plan_type: 'premium' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put "/api/v1/subscriptions/#{id}", headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:subscription_params) { { plan_type: 'premium' } }

        run_test! do
          put "/api/v1/subscriptions/#{id}", headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'subscription not found' do
        let(:id) { 9999 }
        let(:subscription_params) { { plan_type: 'premium' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put "/api/v1/subscriptions/#{id}", headers: headers, params: { subscription: subscription_params }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    delete 'Deletes a subscription' do
      tags 'Subscriptions'
      security [bearer_auth: []]
      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '204', 'subscription deleted' do
        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          delete "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:no_content)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        run_test! do
          delete "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'subscription not found' do
        let(:id) { 9999 }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          delete "/api/v1/subscriptions/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end