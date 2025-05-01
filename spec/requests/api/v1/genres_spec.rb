require 'swagger_helper'

RSpec.describe 'api/v1/genres', type: :request do
  path '/api/v1/genres' do
    get 'Lists all genres' do
      tags 'Genres'
      produces 'application/json'

      response '200', 'genres found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                 }
               }
        run_test!
      end
    end

    post 'Creates a genre' do
      tags 'Genres'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :genre, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '201', 'genre created' do
        let(:Authorization) { 'Bearer valid_token' }
        let(:genre) { { name: 'Action' } }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:genre) { { name: 'Action' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:Authorization) { 'Bearer valid_token' }
        let(:genre) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/genres/{id}' do
    parameter name: 'id', in: :path, type: :integer, required: true

    get 'Retrieves a genre' do
      tags 'Genres'
      produces 'application/json'

      response '200', 'genre found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 movies: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       release_year: { type: :integer },
                       rating: { type: :string },
                       poster_url: { type: :string, nullable: true }
                     }
                   }
                 }
               }
        run_test!
      end

      response '404', 'genre not found' do
        run_test!
      end
    end

    put 'Updates a genre' do
      tags 'Genres'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: :genre, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '200', 'genre updated' do
        let(:Authorization) { 'Bearer valid_token' }
        let(:genre) { { name: 'Updated Genre' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:genre) { { name: 'Updated Genre' } }
        run_test!
      end

      response '404', 'genre not found' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end

    delete 'Deletes a genre' do
      tags 'Genres'
      security [bearer_auth: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true

      response '204', 'genre deleted' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end

      response '422', 'genre has associated movies' do
        let(:Authorization) { 'Bearer valid_token' }
        run_test!
      end
    end
  end
end
