# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Movies API' do
  path '/api/v1/movies' do
    get 'Lists all movies' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :genre_id, in: :query, type: :integer, required: false
      parameter name: :search, in: :query, type: :string, required: false

      response '200', 'movies found' do
        schema type: :object,
               properties: {
                 movies: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/movie' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }
        run_test!
      end
    end

    post 'Creates a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :movie, in: :formData, schema: {
        type: :object,
        properties: {
          'movie[title]': { type: :string },
          'movie[release_year]': { type: :integer },
          'movie[rating]': { type: :string },
          'movie[genre_id]': { type: :integer },
          'movie[poster]': { type: :string, format: 'binary' }
        },
        required: ['movie[title]', 'movie[release_year]', 'movie[rating]', 'movie[genre_id]']
      }

      response '201', 'movie created' do
        schema '$ref' => '#/components/schemas/movie'
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

  path '/api/v1/movies/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retrieves a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'movie found' do
        schema '$ref' => '#/components/schemas/movie'
        run_test!
      end

      response '404', 'movie not found' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end
    end

    patch 'Updates a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :movie, in: :formData, schema: {
        type: :object,
        properties: {
          'movie[title]': { type: :string },
          'movie[release_year]': { type: :integer },
          'movie[rating]': { type: :string },
          'movie[genre_id]': { type: :integer },
          'movie[poster]': { type: :string, format: 'binary' }
        }
      }

      response '200', 'movie updated' do
        schema '$ref' => '#/components/schemas/movie'
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

    delete 'Deletes a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'

      response '204', 'movie deleted' do
        run_test!
      end
    end
  end

  path '/api/v1/movies/search' do
    get 'Search movies' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :q, in: :query, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false

      response '200', 'search results' do
        schema type: :object,
               properties: {
                 movies: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/movie' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/movies/recommended' do
    get 'Get recommended movies' do
      tags 'Movies'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'recommended movies' do
        schema type: :object,
               properties: {
                 movies: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/movie' }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/movies/{id}/rate' do
    parameter name: :id, in: :path, type: :integer

    post 'Rate a movie' do
      tags 'Movies'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :rating, in: :body, schema: {
        type: :object,
        properties: {
          rating: { type: :integer, minimum: 1, maximum: 5 }
        },
        required: ['rating']
      }

      response '200', 'rating saved' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }
        run_test!
      end
    end
  end
end
