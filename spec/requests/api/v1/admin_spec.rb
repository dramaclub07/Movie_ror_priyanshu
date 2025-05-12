# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/admin', type: :request do
  path '/api/v1/admin/users' do
    get 'List all users' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :search, in: :query, type: :string, required: false, description: 'Search by email or phone'

      response '200', 'users found' do
        schema type: :object,
               properties: {
                 users: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       email: { type: :string },
                       phone_number: { type: :string },
                       created_at: { type: :string, format: 'date-time' },
                       subscriptions_count: { type: :integer },
                       role: { type: :string }
                     }
                   }
                 },
                 total_pages: { type: :integer },
                 current_page: { type: :integer },
                 total_count: { type: :integer }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/users/{id}' do
    parameter name: 'id', in: :path, type: :integer, required: true

    get 'Get user details' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'user found' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     role: { type: :string },
                     subscriptions: {
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
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end

      response '404', 'user not found' do
        run_test!
      end
    end

    put 'Update user' do
      tags 'Admin'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          phone_number: { type: :string },
          role: { type: :string, enum: %w[user supervisor] }
        }
      }

      response '200', 'user updated' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     role: { type: :string }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end

      response '404', 'user not found' do
        run_test!
      end

      response '422', 'invalid request' do
        run_test!
      end
    end

    delete 'Delete user' do
      tags 'Admin'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '204', 'user deleted' do
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end

      response '404', 'user not found' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/dashboard' do
    get 'Get dashboard statistics' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '200', 'statistics found' do
        schema type: :object,
               properties: {
                 total_users: { type: :integer },
                 total_movies: { type: :integer },
                 total_subscriptions: { type: :integer },
                 active_subscriptions: { type: :integer },
                 recent_users: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       email: { type: :string },
                       created_at: { type: :string, format: 'date-time' }
                     }
                   }
                 },
                 recent_subscriptions: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       user_email: { type: :string },
                       movie_title: { type: :string },
                       created_at: { type: :string, format: 'date-time' }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end
end
