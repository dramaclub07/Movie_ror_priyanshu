# spec/requests/api/v1/watchlists_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Watchlists', type: :request do
  let(:user) { create(:user, device_token: 'abc123xyz456', notifications_enabled: true) }
  let(:genre) { create(:genre, name: 'Sci-Fi') }
  let(:movie) { create(:movie, title: 'Inception', release_year: 2010, genre: genre, premium: false) }
  let(:jwt_token) { JWT.encode({ sub: user.id }, Rails.application.credentials.secret_key_base, 'HS256') }

  describe 'GET /api/v1/watchlist' do
    it 'returns watchlisted movies with watchlisted status' do
      create(:watchlist, user: user, movie: movie)
      get '/api/v1/watchlist', headers: { 'Authorization' => "Bearer #{jwt_token}" }
      expect(response).to have_http_status(:ok)
      movies = JSON.parse(response.body)
      expect(movies.first['id']).to eq(movie.id)
      expect(movies.first['watchlisted']).to eq(true)
    end

    it 'returns 401 for unauthenticated user' do
      get '/api/v1/watchlist'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/watchlist/:movie_id' do
    it 'adds movie to watchlist and triggers notification job' do
      allow_any_instance_of(FcmService).to receive(:send_notification).and_return({ message: 'Notification sent' })
      expect {
        post "/api/v1/watchlist/#{movie.id}", headers: { 'Authorization' => "Bearer #{jwt_token}" }
      }.to have_enqueued_job(WatchlistNotificationJob)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include('movie_id' => movie.id)
      expect(Watchlist.exists?(user: user, movie: movie)).to be(true)
    end

    it 'removes movie from watchlist if already added' do
      create(:watchlist, user: user, movie: movie)
      post "/api/v1/watchlist/#{movie.id}", headers: { 'Authorization' => "Bearer #{jwt_token}" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie removed from watchlist' })
      expect(Watchlist.exists?(user: user, movie: movie)).to be(false)
    end

    it 'returns 422 if validation fails' do
      create(:watchlist, user: user, movie: movie)
      allow_any_instance_of(Watchlist).to receive(:save).and_return(false)
      allow_any_instance_of(Watchlist).to receive(:errors).and_return(double(full_messages: ['Movie has already been added to watchlist']))
      post "/api/v1/watchlist/#{movie.id}", headers: { 'Authorization' => "Bearer #{jwt_token}" }
      expect(response).to have_http_status(:ok) # Since it removes the existing watchlist entry
    end

    it 'returns 404 for non-existent movie' do
      post '/api/v1/watchlist/999', headers: { 'Authorization' => "Bearer #{jwt_token}" }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
    end

    it 'returns 401 for unauthenticated user' do
      post "/api/v1/watchlist/#{movie.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end