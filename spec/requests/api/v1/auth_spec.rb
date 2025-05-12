# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth API' do
  path '/api/v1/register' do
    post 'Creates a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
              phone_number: { type: :string, pattern: '^[6789]\\d{9}$' },
              name: { type: :string }
            },
            required: %w[email password password_confirmation phone_number name]
          }
        }
      }

      response '201', 'user created' do
        let(:user) do
          {
            user: {
              email: "newuser_#{SecureRandom.hex(4)}@example.com",
              password: 'Password123',
              password_confirmation: 'Password123',
              phone_number: '7890123456',
              name: 'New User'
            }
          }
        end
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     name: { type: :string },
                     role: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 },
                 message: { type: :string },
                 auth_info: {
                   type: :object,
                   properties: {
                     status: { type: :string },
                     token_type: { type: :string },
                     access_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     refresh_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     cookie_info: {
                       type: :object,
                       properties: {
                         access_token_cookie: { type: :string },
                         refresh_token_cookie: { type: :string },
                         secure: { type: :boolean },
                         same_site: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test! do
          post '/api/v1/register', params: user, as: :json
        end
      end

      response '422', 'invalid request' do
        let(:user) do
          {
            user: {
              email: 'invalid',
              password: 'short',
              password_confirmation: 'different',
              phone_number: '1234567890',
              name: ''
            }
          }
        end
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               }
        run_test! do
          post '/api/v1/register', params: user, as: :json
        end
      end
    end
  end

  path '/api/v1/login' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      response '200', 'user signed in' do
        let(:user_record) do
          create(:user, email: "test_#{SecureRandom.hex(4)}@example.com", password: 'Password123', name: 'Test User',
                        phone_number: '7890123456', role: 'user')
        end
        let(:user) do
          {
            user: {
              email: user_record.email,
              password: 'Password123'
            }
          }
        end
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string },
                     name: { type: :string },
                     role: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 },
                 message: { type: :string },
                 auth_info: {
                   type: :object,
                   properties: {
                     status: { type: :string },
                     token_type: { type: :string },
                     access_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     refresh_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     cookie_info: {
                       type: :object,
                       properties: {
                         access_token_cookie: { type: :string },
                         refresh_token_cookie: { type: :string },
                         secure: { type: :boolean },
                         same_site: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test! do
          post '/api/v1/login', params: user, as: :json
        end
      end

      response '401', 'invalid credentials' do
        let(:user_record) do
          create(:user, email: "test_#{SecureRandom.hex(4)}@example.com", password: 'Password123', name: 'Test User',
                        phone_number: '7890123456', role: 'user')
        end
        let(:user) do
          {
            user: {
              email: user_record.email,
              password: 'wrong'
            }
          }
        end
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test! do
          post '/api/v1/login', params: user, as: :json
        end
      end
    end
  end

  path '/api/v1/auth/google' do
    post 'Signs in or creates a user with Google' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []
      parameter name: :token, in: :body, schema: {
        type: :object,
        properties: {
          access_token: { type: :string }
        },
        required: ['access_token']
      }

      response '200', 'successful authentication' do
        let(:google_email) { "google_#{SecureRandom.hex(4)}@example.com" }
        before do
          allow_any_instance_of(OAuth2::AccessToken).to receive(:get).and_return(
            double(body: { sub: '123', email: google_email, name: 'Test User' }.to_json)
          )
        end
        let(:token) { { access_token: 'mock-google-token' } }
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     phone_number: { type: :string, nullable: true },
                     name: { type: :string },
                     role: { type: :string },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 },
                 message: { type: :string },
                 auth_info: {
                   type: :object,
                   properties: {
                     status: { type: :string },
                     token_type: { type: :string },
                     access_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     refresh_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     cookie_info: {
                       type: :object,
                       properties: {
                         access_token_cookie: { type: :string },
                         refresh_token_cookie: { type: :string },
                         secure: { type: :boolean },
                         same_site: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test! do
          post '/api/v1/auth/google', params: token, as: :json
        end
      end

      response '401', 'authentication failed' do
        before do
          allow_any_instance_of(OAuth2::AccessToken).to receive(:get).and_raise(OAuth2::Error.new('Invalid token'))
        end
        let(:token) { { access_token: 'invalid-token' } }
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test! do
          post '/api/v1/auth/google', params: token, as: :json
        end
      end
    end
  end

  path '/api/v1/logout' do
    delete 'Signs out a user' do
      tags 'Authentication'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'signed out successfully' do
        let(:user) do
          create(:user, email: "test_#{SecureRandom.hex(4)}@example.com", password: 'Password123', name: 'Test User',
                        phone_number: '7890123456', role: 'user')
        end
        let(:jwt_token) do
          tokens = JwtService.generate_tokens(user.id)
          user.update!(refresh_token: tokens[:refresh_token])
          tokens[:access_token]
        end
        let(:Authorization) { "Bearer #{jwt_token}" }
        schema type: :object,
               properties: {
                 message: { type: :string },
                 auth_info: {
                   type: :object,
                   properties: {
                     status: { type: :string },
                     tokens_cleared: { type: :boolean }
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/refresh-token' do
    post 'Refreshes authentication tokens' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []

      response '200', 'tokens refreshed' do
        let(:user) do
          create(:user, email: "test_#{SecureRandom.hex(4)}@example.com", password: 'Password123', name: 'Test User',
                        phone_number: '7890123456', role: 'user')
        end
        let(:refresh_token) do
          tokens = JwtService.generate_tokens(user.id)
          user.update!(refresh_token: tokens[:refresh_token])
          tokens[:refresh_token]
        end
        before do
          cookies[:refresh_token] = refresh_token
        end
        schema type: :object,
               properties: {
                 message: { type: :string },
                 auth_info: {
                   type: :object,
                   properties: {
                     status: { type: :string },
                     token_type: { type: :string },
                     access_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     refresh_token: {
                       type: :object,
                       properties: {
                         present: { type: :boolean },
                         expires_in: { type: :integer },
                         expires_at: { type: :integer },
                         token: { type: :string }
                       }
                     },
                     cookie_info: {
                       type: :object,
                       properties: {
                         access_token_cookie: { type: :string },
                         refresh_token_cookie: { type: :string },
                         secure: { type: :boolean },
                         same_site: { type: :string }
                       }
                     }
                   }
                 }
               }
        run_test! do
          post '/api/v1/refresh-token', as: :json
        end
      end

      response '401', 'invalid refresh token' do
        before do
          cookies[:refresh_token] = 'invalid-token'
        end
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test! do
          post '/api/v1/refresh-token', as: :json
        end
      end
    end
  end
end
