# spec/requests/api/v1/genres_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Genres', type: :request do
  let(:user) { create(:user) }
  let(:supervisor) { create(:user, role: 'supervisor') }
  let(:headers) { { 'Authorization' => "Bearer #{JwtService.generate_tokens(supervisor.id)[:access_token]}" } }
  let(:user_headers) { { 'Authorization' => "Bearer #{JwtService.generate_tokens(user.id)[:access_token]}" } }

  describe 'GET /api/v1/genres' do
    it 'returns all genres' do
      create_list(:genre, 3)
      get '/api/v1/genres'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET /api/v1/genres/:id' do
    it 'returns the genre with movies' do
      genre = create(:genre)
      get "/api/v1/genres/#{genre.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(genre.id)
    end

    it 'returns 404 if genre not found' do
      get '/api/v1/genres/9999'
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Genre not found')
    end
  end

  describe 'POST /api/v1/genres' do
    let(:valid_params) { { genre: { name: 'Thriller' } } }

    it 'creates a genre as supervisor' do
      post '/api/v1/genres', params: valid_params, headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['name']).to eq('Thriller')
    end

    it 'returns 422 for invalid params' do
      post '/api/v1/genres', params: { genre: { name: '' } }, headers: headers
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
    end

    it 'returns forbidden for non-supervisor' do
      post '/api/v1/genres', params: valid_params, headers: user_headers
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized access')
    end

    it 'returns unauthorized for unauthenticated' do
      post '/api/v1/genres', params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/genres/:id' do
    let(:genre) { create(:genre, name: 'Old') }
    let(:params) { { genre: { name: 'New' } } }

    it 'updates genre as supervisor' do
      put "/api/v1/genres/#{genre.id}", params: params, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq('New')
    end

    it 'returns 404 if genre not found' do
      put '/api/v1/genres/9999', params: params, headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns forbidden for non-supervisor' do
      put "/api/v1/genres/#{genre.id}", params: params, headers: user_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/v1/genres/:id' do
    let!(:genre) { create(:genre) }

    it 'deletes genre as supervisor' do
      delete "/api/v1/genres/#{genre.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns error if genre has movies' do
      create(:movie, genre: genre)
      delete "/api/v1/genres/#{genre.id}", headers: headers
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)['error']).to eq('Cannot delete genre with associated movies')
    end

    it 'returns forbidden for non-supervisor' do
      delete "/api/v1/genres/#{genre.id}", headers: user_headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end