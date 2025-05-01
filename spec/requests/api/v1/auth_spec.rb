require 'swagger_helper'

RSpec.describe 'Auth API' do
  path '/api/v1/auth/sign_up' do
    post 'Creates a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
              phone_number: { type: :string }
            },
            required: %w[email password password_confirmation phone_number]
          }
        }
      }

      response '201', 'user created' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string }
                   }
                 },
                 token: { type: :string }
               }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response '200', 'user signed in' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string }
                   }
                 },
                 token: { type: :string }
               }
        run_test!
      end

      response '401', 'invalid credentials' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end
    end
  end

  path '/api/v1/auth/google' do
    post 'Signs in or creates a user with Google' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :token, in: :body, schema: {
        type: :object,
        properties: {
          access_token: { type: :string }
        },
        required: ['access_token']
      }

      response '200', 'successful authentication' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string }
                   }
                 },
                 token: { type: :string }
               }
        run_test!
      end

      response '401', 'authentication failed' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete 'Signs out a user' do
      tags 'Authentication'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'signed out successfully' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }
        run_test!
      end
    end
  end
end
