require 'rails_helper'
RSpec.describe Api::V1::MoviesController, type: :request do
  let(:user) { create(:user) }
  let(:supervisor) { create(:user, role: 'supervisor') }
  let(:genre) { create(:genre) }
  let(:movie) { create(:movie, genre: genre, premium: false) }
  let(:premium_movie) { create(:movie, genre: genre, premium: true) }
  let(:user_token) { JwtService.encode(user_id: user.id) }
  let(:supervisor_token) { JwtService.encode(user_id: supervisor.id) }
  let(:user_headers) { { 'Authorization' => "Bearer #{user_token}" } }
  let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }

  describe 'GET /api/v1/movies' do
    context 'without authentication' do
      it 'returns non-premium movies with pagination' do
        create_list(:movie, 2, genre: genre, premium: false)
        create(:movie, genre: genre, premium: true)
        get '/api/v1/movies', headers: user_headers, params: { page: 1, per: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].length).to eq(3)
      end
    end

    context 'with search query' do
      it 'returns movies matching the search term' do
        create(:movie, title: 'Example Movie', genre: genre, premium: false)
        get '/api/v1/movies', params: { search: 'Example' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].first['title']).to eq('Example Movie')
      end
    end
  end

  describe 'GET /api/v1/movies/:id' do
    context 'for non-premium movie' do
      it 'returns the movie without authentication' do
        get "/api/v1/movies/#{movie.id}"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('id' => movie.id, 'title' => movie.title)
      end
    end

    context 'for premium movie without subscription' do
      it 'returns 403 forbidden' do
        get "/api/v1/movies/#{premium_movie.id}"

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Premium subscription required' })
      end
    end

    context 'for premium movie with subscription' do
      before do
        create(:subscription, user: user, status: 'active', plan_type: 'premium')
      end

      it 'returns the movie' do
        get "/api/v1/movies/#{premium_movie.id}", headers: user_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('id' => premium_movie.id, 'title' => premium_movie.title)
      end
    end

    context 'for non-existent movie' do
      it 'returns 404' do
        get '/api/v1/movies/999'

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
      end
    end
  end

  describe 'POST /api/v1/movies' do
    let(:movie_params) do
      {
        movie: {
          title: 'New Movie',
          genre_id: genre.id,
          premium: false,
          release_year: 2020,
          description: 'A test movie',
          director: 'Test Director',
          duration: 120,
          main_lead: 'Test Actor',
          streaming_platform: 'Test Platform',
          rating: 7.5 
        }
      }
    end

    context 'with invalid params' do
      it 'returns 422 with validation errors' do
        post '/api/v1/movies', params: { movie: { title: '', genre_id: genre.id } }, headers: supervisor_headers

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)).to include('errors')
      end
    end

    context 'with non-supervisor authentication' do
      it 'returns 401 unauthorized' do
        post '/api/v1/movies', params: movie_params, headers: user_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end

    context 'with supervisor authentication and file uploads' do
      it 'creates a new movie with poster and banner' do
        poster = fixture_file_upload(Rails.root.join('spec/fixtures/files/poster.png'), 'image/png')
        banner = fixture_file_upload(Rails.root.join('spec/fixtures/files/banner.png'), 'image/png')
        params = movie_params.deep_merge(movie: { poster: poster, banner: banner })
        post '/api/v1/movies', params: params, headers: supervisor_headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['movie']['title']).to eq('New Movie')
        expect(json['movie']).to have_key('poster_url')
        expect(json['movie']).to have_key('banner_url')
      end
    end

    context 'with supervisor authentication and valid params' do
      it 'creates a new movie and returns 201' do
        post '/api/v1/movies', params: movie_params, headers: supervisor_headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['movie']['title']).to eq('New Movie')
      end
    end
  end

  describe 'PATCH /api/v1/movies/:id' do
    let(:movie_params) { { movie: { title: 'Updated Movie' } } }

    context 'with supervisor authentication' do
      it 'updates the movie and returns 200' do
        patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: supervisor_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('title' => 'Updated Movie')
      end
    end

    context 'with invalid params' do
      it 'returns 422 with validation errors' do
        patch "/api/v1/movies/#{movie.id}", params: { movie: { title: '' } }, headers: supervisor_headers

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)).to include('errors')
      end
    end

    context 'with non-supervisor authentication' do
      it 'returns 401 unauthorized' do
        patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: user_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end

  describe 'DELETE /api/v1/movies/:id' do
    context 'with supervisor authentication' do
      it 'deletes the movie and returns 200' do
        delete "/api/v1/movies/#{movie.id}", headers: supervisor_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie deleted successfully' })
        expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with non-supervisor authentication' do
      it 'returns 401 unauthorized' do
        delete "/api/v1/movies/#{movie.id}", headers: user_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
end
