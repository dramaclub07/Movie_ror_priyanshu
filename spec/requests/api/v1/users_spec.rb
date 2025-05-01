require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users/profile' do
    get 'Get user profile' do
      tags 'Users'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'profile found' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     subscriptions_count: { type: :integer },
                     active_subscriptions: {
                       type: :array,
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
                               title: { type: :string }
                             }
                           }
                         }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
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
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     created_at: { type: :string, format: 'date-time' }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     phone_number: { type: :array, items: { type: :string } },
                     current_password: { type: :array, items: { type: :string } },
                     password: { type: :array, items: { type: :string } }
                   }
                 }
               }
        run_test!
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
        schema type: :object,
               properties: {
                 email_notifications: { type: :boolean },
                 push_notifications: { type: :boolean },
                 sms_notifications: { type: :boolean }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
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
        schema type: :object,
               properties: {
                 email_notifications: { type: :boolean },
                 push_notifications: { type: :boolean },
                 sms_notifications: { type: :boolean }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end

      response '422', 'invalid request' do
        run_test!
      end
    end
  end
end
