require 'swagger_helper'

RSpec.describe 'api/v1/subscriptions', type: :request do
  path '/api/v1/subscriptions' do
    get 'Lists user subscriptions' do
      tags 'Subscriptions'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'subscriptions found' do
        let(:Authorization) { 'Bearer valid_token' }
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   plan_type: { type: :string },
                   status: { type: :string },
                   movie: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       release_year: { type: :integer },
                       rating: { type: :string },
                       poster_url: { type: :string, nullable: true },
                       genre: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string }
                         }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
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
        let(:Authorization) { 'Bearer valid_token' }
        let(:subscription) { { plan_type: 'basic', status: 'active' } }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 plan_type: { type: :string },
                 status: { type: :string },
                 movie: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     title: { type: :string },
                     release_year: { type: :integer },
                     rating: { type: :string },
                     poster_url: { type: :string, nullable: true },
                     genre: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:subscription) { { plan_type: 'basic', status: 'active' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    parameter name: 'id', in: :path, type: :integer, required: true

    get 'Retrieves a subscription' do
      tags 'Subscriptions'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'subscription found' do
        let(:Authorization) { 'Bearer valid_token' }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 plan_type: { type: :string },
                 status: { type: :string },
                 movie: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     title: { type: :string },
                     release_year: { type: :integer },
                     rating: { type: :string },
                     poster_url: { type: :string, nullable: true },
                     genre: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end

      response '404', 'subscription not found' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end

    put 'Updates a subscription' do
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
        }
      }

      response '200', 'subscription updated' do
        let(:Authorization) { 'Bearer valid_token' }
        let(:subscription) { { plan_type: 'premium' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:subscription) { { plan_type: 'premium' } }
        run_test!
      end

      response '404', 'subscription not found' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end

    delete 'Deletes a subscription' do
      tags 'Subscriptions'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '204', 'subscription deleted' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end

      response '404', 'subscription not found' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end
  end
end
