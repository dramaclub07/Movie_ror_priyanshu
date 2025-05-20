require 'swagger_helper'

RSpec.describe 'api/v1/subscriptions', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{JwtService.generate_tokens(user.id)[:access_token]}" } }

  path '/api/v1/subscriptions' do
    get 'Lists user subscriptions' do
      tags 'Subscriptions'
      produces 'application/json'

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

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(nil)
        end

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
      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          plan_type: { type: :string, enum: %w[basic premium] },
          status: { type: :string, enum: %w[active inactive] }
        },
        required: %w[plan_type status]
      }

      response '200', 'subscription created' do
        let(:subscription) { { plan_type: 'basic', status: 'active' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
          allow(StripeSubscriptionService).to receive(:create_checkout_session).and_return(
            OpenStruct.new(
              success?: true,
              session: OpenStruct.new(id: 'sess_123', url: 'https://stripe.com/session'),
              subscription: create(:subscription, user: user)
            )
          )
        end

        run_test! do
          post '/api/v1/subscriptions', params: subscription, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:subscription) { { plan_type: 'basic', status: 'active' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(nil)
        end

        run_test! do
          post '/api/v1/subscriptions', params: subscription, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '422', 'invalid request' do
        let(:subscription) { { plan_type: 'invalid', status: 'active' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
          allow(StripeSubscriptionService).to receive(:create_checkout_session).and_return(
            OpenStruct.new(success?: false, error: 'Invalid plan type')
          )
        end

        run_test! do
          post '/api/v1/subscriptions', params: subscription, headers: headers
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true
    let(:subscription_record) { create(:subscription, user: user) }
    let(:id) { subscription_record.id }

    get 'Retrieves a subscription' do
      tags 'Subscriptions'
      produces 'application/json'

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

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(nil)
        end

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
      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          plan_type: { type: :string, enum: %w[basic premium] },
          status: { type: :string, enum: %w[active inactive] }
        }
      }

      response '200', 'subscription updated' do
        let(:subscription) { { plan_type: 'premium' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put "/api/v1/subscriptions/#{id}", params: { subscription: subscription }, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }
        let(:subscription) { { plan_type: 'premium' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(nil)
        end

        run_test! do
          put "/api/v1/subscriptions/#{id}", params: { subscription: subscription }, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'subscription not found' do
        let(:id) { 9999 }
        let(:subscription) { { plan_type: 'premium' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          put "/api/v1/subscriptions/#{id}", params: { subscription: subscription }, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  path '/api/v1/subscriptions/active' do
    get 'Retrieves active subscription' do
      tags 'Subscriptions'
      produces 'application/json'

      response '200', 'active subscription found' do
        let!(:subscription) { create(:subscription, user: user, status: 'active') }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get '/api/v1/subscriptions/active', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '401', 'unauthorized' do
        let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(nil)
        end

        run_test! do
          get '/api/v1/subscriptions/active', headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'no active subscription' do
        before do
          allow_any_instance_of(Api::V1::SubscriptionsController).to receive(:current_user).and_return(user)
        end

        run_test! do
          get '/api/v1/subscriptions/active', headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  path '/api/v1/subscriptions/success' do
    get 'Completes subscription' do
      tags 'Subscriptions'
      produces 'application/json'
      parameter name: :session_id, in: :query, type: :string, required: true

      response '200', 'subscription activated' do
        let(:session_id) { 'sess_123' }

        before do
          allow(StripeSubscriptionService).to receive(:complete_subscription).and_return(
            OpenStruct.new(
              success?: true,
              subscription: create(:subscription, user: user)
            )
          )
        end

        run_test! do
          get '/api/v1/subscriptions/success', params: { session_id: session_id }, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid session' do
        let(:session_id) { 'invalid_session' }

        before do
          allow(StripeSubscriptionService).to receive(:complete_subscription).and_return(
            OpenStruct.new(success?: false, error: 'Invalid session')
          )
        end

        run_test! do
          get '/api/v1/subscriptions/success', params: { session_id: session_id }, headers: headers
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  path '/api/v1/subscriptions/cancel' do
    get 'Cancels payment' do
      tags 'Subscriptions'
      produces 'application/json'

      response '200', 'payment cancelled' do
        run_test! do
          get '/api/v1/subscriptions/cancel', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end