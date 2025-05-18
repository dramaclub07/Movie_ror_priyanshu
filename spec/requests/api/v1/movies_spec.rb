require 'swagger_helper'

RSpec.describe 'Movies API', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:auth_headers) { auth_headers_for(admin) }
  let(:genre) { create(:genre) }
  let(:movie) { create(:movie, genre: genre) }
  let(:token) { JwtService.encode({ user_id: user.id }) }

  # Schema configuration
  before(:all) do
    RSpec.configure do |config|
      config.openapi_specs['v1/swagger.yaml'][:components] = {
        schemas: {
          movie: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              release_year: { type: :integer },
              genre_id: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      }
    end
  end

  path '/api/v1/movies' do
    get 'Lists all movies' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'movies found' do
        let(:Authorization) { auth_headers['Authorization'] }

        before do
          create_list(:movie, 3, genre: genre)
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        before do
          allow_any_instance_of(ApplicationController)
            .to receive(:authenticate_user!)
            .and_raise(JWT::DecodeError)
        end

        run_test!
      end
    end

    post 'Creates a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :movie, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          genre_id: { type: :integer }
        },
        required: ['title', 'genre_id']
      }

      response '201', 'movie created' do
        let(:Authorization) { auth_headers['Authorization'] }
        let(:movie) { { title: 'Test Movie', genre_id: genre.id } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:Authorization) { auth_headers['Authorization'] }
        let(:movie) { { title: '' } }

        run_test!
      end
    end
  end

  path '/api/v1/movies/{id}' do
    parameter name: :id, in: :path, type: :integer

    let(:existing_movie) { create(:movie, genre: genre) }
    let(:id) { existing_movie.id }

    get 'Retrieves a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'movie found' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
        end
      end

      response '404', 'movie not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 0 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    patch 'Updates a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :movie, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        }
      }

      response '200', 'movie updated' do
        let(:Authorization) { "Bearer #{token}" }
        let(:movie) { { title: 'Updated Title' } }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:movie) { { title: '' } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    delete 'Deletes a movie' do
      tags 'Movies'
      security [bearer_auth: []]

      response '204', 'movie deleted' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end

  path '/api/v1/movies/search' do
    get 'Search movies' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :q, in: :query, type: :string

      response '200', 'search results' do
        let(:Authorization) { auth_headers['Authorization'] }
        let(:q) { movie.title }

        before do
          movie # create the movie
        end

        run_test!
      end
    end
  end
end
