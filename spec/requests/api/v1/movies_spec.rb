# # spec/requests/api/v1/movies_controller_spec.rb
# require 'rails_helper'

# RSpec.describe Api::V1::MoviesController, type: :request do
#   let(:user) { create(:user) }
#   let(:supervisor) { create(:user, role: 'supervisor') }
#   let(:genre) { create(:genre) }
#   let(:movie) { create(:movie, genre: genre, premium: false) }
#   let(:premium_movie) { create(:movie, genre: genre, premium: true) }
#   let(:user_token) { JwtService.encode(user_id: user.id) }
#   let(:supervisor_token) { JwtService.encode(user_id: supervisor.id) }
#   let(:user_headers) { { 'Authorization' => "Bearer #{user_token}" } }
#   let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }

#   describe 'GET /api/v1/movies' do
#     context 'without authentication' do
#       it 'returns non-premium movies with pagination' do
#         create_list(:movie, 3, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true) # Should be excluded
#         get '/api/v1/movies', params: { page: 1, per: 2 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies']).to be_an(Array)
#         expect(json['movies'].length).to eq(2)
#         # expect(json['meta']).to include('current_page' => 1, 'total_pages', 'total_count')
#         expect(json['meta']).to include('current_page' => 1, 'total_pages' => be_a(Integer), 'total_count' => be_a(Integer))
#       end
#     end

#     context 'with premium subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan: 'premium')
#       end

#       it 'returns all movies including premium' do
#         create_list(:movie, 2, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true)
#         get '/api/v1/movies', headers: user_headers

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].length).to eq(3)
#       end
#     end

#     context 'with search query' do
#       it 'returns movies matching the search term' do
#         create(:movie, title: 'Example Movie', genre: genre, premium: false)
#         get '/api/v1/movies', params: { search: 'Example' }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].first['title']).to eq('Example Movie')
#       end
#     end
#   end

#   describe 'GET /api/v1/movies/:id' do
#     context 'for non-premium movie' do
#       it 'returns the movie without authentication' do
#         get "/api/v1/movies/#{movie.id}"

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => movie.id, 'title' => movie.title)
#       end
#     end

#     context 'for premium movie without subscription' do
#       it 'returns 403 forbidden' do
#         get "/api/v1/movies/#{premium_movie.id}"

#         expect(response).to have_http_status(:forbidden)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Premium subscription required' })
#       end
#     end

#     context 'for premium movie with subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan: 'premium')
#       end

#       it 'returns the movie' do
#         get "/api/v1/movies/#{premium_movie.id}", headers: user_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => premium_movie.id, 'title' => premium_movie.title)
#       end
#     end

#     context 'for non-existent movie' do
#       it 'returns 404' do
#         get '/api/v1/movies/999'

#         expect(response).to have_http_status(:not_found)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
#       end
#     end
#   end

#   describe 'POST /api/v1/movies' do
#     let(:movie_params) { { movie: { title: 'New Movie', genre_id: genre.id, premium: false } } }

#     context 'with supervisor authentication' do
#       it 'creates a movie and returns 201' do
#         post '/api/v1/movies', params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:created)
#         expect(JSON.parse(response.body)['movie']).to include('title' => 'New Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         post '/api/v1/movies', params: { movie: { title: '', genre_id: genre.id } }, headers: supervisor_headers

#         expect(response).to have_http_status(:unprocessable_entity)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         post '/api/v1/movies', params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'PATCH /api/v1/movies/:id' do
#     let(:movie_params) { { movie: { title: 'Updated Movie' } } }

#     context 'with supervisor authentication' do
#       it 'updates the movie and returns 200' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('title' => 'Updated Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         patch "/api/v1/movies/#{movie.id}", params: { movie: { title: '' } }, headers: supervisor_headers

#         expect(response).to have_http_status(:unprocessable_entity)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'DELETE /api/v1/movies/:id' do
#     context 'with supervisor authentication' do
#       it 'deletes the movie and returns 200' do
#         delete "/api/v1/movies/#{movie.id}", headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie deleted successfully' })
#         expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         delete "/api/v1/movies/#{movie.id}", headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end
# end

# spec/requests/api/v1/movies_spec.rb
# require 'rails_helper'

# RSpec.describe Api::V1::MoviesController, type: :request do
#   let(:user) { create(:user) }
#   let(:supervisor) { create(:user, role: 'supervisor') }
#   let(:genre) { create(:genre) }
#   let(:movie) { create(:movie, genre: genre, premium: false) }
#   let(:premium_movie) { create(:movie, genre: genre, premium: true) }
#   let(:user_token) { JwtService.encode(user_id: user.id) }
#   let(:supervisor_token) { JwtService.encode(user_id: supervisor.id) }
#   let(:user_headers) { { 'Authorization' => "Bearer #{user_token}" } }
#   let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }

#   describe 'GET /api/v1/movies' do
#     context 'without authentication' do
#       it 'returns non-premium movies with pagination' do
#         create_list(:movie, 3, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true) # Should be excluded
#         get '/api/v1/movies', params: { page: 1, per: 2 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies']).to be_an(Array)
#         expect(json['movies'].length).to be <= 2 # Account for pagination
#         expect(json['movies'].all? { |m| m['premium'] == false }).to be true
#         expect(json['meta']).to include(
#           'current_page' => 1,
#           'total_pages' => be_a(Integer),
#           'total_count' => be_a(Integer)
#         )
#       end
#     end

#     context 'with premium subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns all movies including premium' do
#         create_list(:movie, 2, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true)
#         get '/api/v1/movies', headers: user_headers, params: { page: 1, per: 10 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].length).to eq(3)
#       end
#     end

#     context 'with search query' do
#       it 'returns movies matching the search term' do
#         create(:movie, title: 'Example Movie', genre: genre, premium: false)
#         get '/api/v1/movies', params: { search: 'Example' }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].first['title']).to eq('Example Movie')
#       end
#     end
#   end

#   describe 'GET /api/v1/movies/:id' do
#     context 'for non-premium movie' do
#       it 'returns the movie without authentication' do
#         get "/api/v1/movies/#{movie.id}"

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => movie.id, 'title' => movie.title)
#       end
#     end

#     context 'for premium movie without subscription' do
#       it 'returns 403 forbidden' do
#         get "/api/v1/movies/#{premium_movie.id}"

#         expect(response).to have_http_status(:forbidden)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Premium subscription required' })
#       end
#     end

#     context 'for premium movie with subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns the movie' do
#         get "/api/v1/movies/#{premium_movie.id}", headers: user_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => premium_movie.id, 'title' => premium_movie.title)
#       end
#     end

#     context 'for non-existent movie' do
#       it 'returns 404' do
#         get '/api/v1/movies/999'

#         expect(response).to have_http_status(:not_found)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
#       end
#     end
#   end

#   describe 'POST /api/v1/movies' do
#     let(:movie_params) do
#       {
#         movie: {
#           title: 'New Movie',
#           genre_id: genre.id,
#           premium: false,
#           release_year: 2020,
#           description: 'A test movie',
#           director: 'Test Director',
#           duration: 120,
#           main_lead: 'Test Actor',
#           streaming_platform: 'Test Platform'
#         }
#       }
#     end

#     context 'with supervisor authentication' do
#       it 'creates a movie and returns 201' do
#         post '/api/v1/movies', params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:created)
#         expect(JSON.parse(response.body)['movie']).to include('title' => 'New Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         post '/api/v1/movies', params: { movie: { title: '', genre_id: genre.id } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         post '/api/v1/movies', params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'PATCH /api/v1/movies/:id' do
#     let(:movie_params) { { movie: { title: 'Updated Movie' } } }

#     context 'with supervisor authentication' do
#       it 'updates the movie and returns 200' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('title' => 'Updated Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         patch "/api/v1/movies/#{movie.id}", params: { movie: { title: '' } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'DELETE /api/v1/movies/:id' do
#     context 'with supervisor authentication' do
#       it 'deletes the movie and returns 200' do
#         delete "/api/v1/movies/#{movie.id}", headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie deleted successfully' })
#         expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         delete "/api/v1/movies/#{movie.id}", headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end
# end

# spec/requests/api/v1/movies_spec.rb
require 'rails_helper'

# RSpec.describe Api::V1::MoviesController, type: :request do
#   let(:user) { create(:user) }
#   let(:supervisor) { create(:user, role: 'supervisor') }
#   let(:genre) { create(:genre) }
#   let(:movie) { create(:movie, genre: genre, premium: false) }
#   let(:premium_movie) { create(:movie, genre: genre, premium: true) }
#   let(:user_token) { JwtService.encode(user_id: user.id) }
#   let(:supervisor_token) { JwtService.encode(user_id: supervisor.id) }
#   let(:user_headers) { { 'Authorization' => "Bearer #{user_token}" } }
#   let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }

#   describe 'GET /api/v1/movies' do
#     context 'without authentication' do
#       it 'returns non-premium movies with pagination' do
#         create_list(:movie, 3, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true) # Should be excluded
#         get '/api/v1/movies', params: { page: 1, per: 2 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies']).to be_an(Array)
#         expect(json['movies'].length).to be <= 2 # Account for pagination
#         expect(json['movies'].all? { |m| m['premium'] == false }).to be true
#         expect(json['meta']).to include(
#           'current_page' => 1,
#           'total_pages' => be_a(Integer),
#           'total_count' => be_a(Integer)
#         )
#       end
#     end

#     context 'with premium subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns all movies including premium' do
#         create_list(:movie, 2, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true)
#         get '/api/v1/movies', headers: user_headers, params: { page: 1, per: 10 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].length).to eq(3)
#       end
#     end

#     context 'with search query' do
#       it 'returns movies matching the search term' do
#         create(:movie, title: 'Example Movie', genre: genre, premium: false)
#         get '/api/v1/movies', params: { search: 'Example' }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].first['title']).to eq('Example Movie')
#       end
#     end
#   end

#   describe 'GET /api/v1/movies/:id' do
#     context 'for non-premium movie' do
#       it 'returns the movie without authentication' do
#         get "/api/v1/movies/#{movie.id}"

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => movie.id, 'title' => movie.title)
#       end
#     end

#     context 'for premium movie without subscription' do
#       it 'returns 403 forbidden' do
#         get "/api/v1/movies/#{premium_movie.id}"

#         expect(response).to have_http_status(:forbidden)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Premium subscription required' })
#       end
#     end

#     context 'for premium movie with subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns the movie' do
#         get "/api/v1/movies/#{premium_movie.id}", headers: user_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => premium_movie.id, 'title' => premium_movie.title)
#       end
#     end

#     context 'for non-existent movie' do
#       it 'returns 404' do
#         get '/api/v1/movies/999'

#         expect(response).to have_http_status(:not_found)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
#       end
#     end
#   end

#   describe 'POST /api/v1/movies' do
#     let(:movie_params) do
#       {
#         movie: {
#           title: 'New Movie',
#           genre_id: genre.id,
#           premium: false,
#           release_year: 2020,
#           description: 'A test movie',
#           director: 'Test Director',
#           duration: 120,
#           main_lead: 'Test Actor',
#           streaming_platform: 'Test Platform'
#         }
#       }
#     end

#     context 'with supervisor authentication' do
#       it 'creates a movie and returns 201' do
#         post '/api/v1/movies', params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:created)
#         expect(JSON.parse(response.body)['movie']).to include('title' => 'New Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         post '/api/v1/movies', params: { movie: { title: '', genre_id: genre.id } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         post '/api/v1/movies', params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'PATCH /api/v1/movies/:id' do
#     let(:movie_params) { { movie: { title: 'Updated Movie' } } }

#     context 'with supervisor authentication' do
#       it 'updates the movie and returns 200' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('title' => 'Updated Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         patch "/api/v1/movies/#{movie.id}", params: { movie: { title: '' } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'DELETE /api/v1/movies/:id' do
#     context 'with supervisor authentication' do
#       it 'deletes the movie and returns 200' do
#         delete "/api/v1/movies/#{movie.id}", headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie deleted successfully' })
#         expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         delete "/api/v1/movies/#{movie.id}", headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end
# end

# spec/requests/api/v1/movies_spec.rb
require 'rails_helper'

# RSpec.describe Api::V1::MoviesController, type: :request do
#   let(:user) { create(:user) }
#   let(:supervisor) { create(:user, role: 'supervisor') }
#   let(:genre) { create(:genre) }
#   let(:movie) { create(:movie, genre: genre, premium: false) }
#   let(:premium_movie) { create(:movie, genre: genre, premium: true) }
#   let(:user_token) { JwtService.encode(user_id: user.id) }
#   let(:supervisor_token) { JwtService.encode(user_id: supervisor.id) }
#   let(:user_headers) { { 'Authorization' => "Bearer #{user_token}" } }
#   let(:supervisor_headers) { { 'Authorization' => "Bearer #{supervisor_token}" } }

#   describe 'GET /api/v1/movies' do
#     context 'without authentication' do
#       it 'returns non-premium movies with pagination' do
#         create_list(:movie, 3, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true) # Should be excluded
#         get '/api/v1/movies', params: { page: 1, per: 2 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies']).to be_an(Array)
#         expect(json['movies'].length).to eq(3) # Expect all 3 non-premium movies
#         expect(json['movies'].all? { |m| m['premium'] == false }).to be true
#         expect(json['meta']).to include(
#           'current_page' => 1,
#           'total_pages' => be_a(Integer),
#           'total_count' => be_a(Integer)
#         )
#       end
#     end

#     context 'with premium subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns all movies including premium' do
#         create_list(:movie, 2, genre: genre, premium: false)
#         create(:movie, genre: genre, premium: true)
#         get '/api/v1/movies', headers: user_headers, params: { page: 1, per: 10 }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].length).to eq(3)
#       end
#     end

#     context 'with search query' do
#       it 'returns movies matching the search term' do
#         create(:movie, title: 'Example Movie', genre: genre, premium: false)
#         get '/api/v1/movies', params: { search: 'Example' }

#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['movies'].first['title']).to eq('Example Movie')
#       end
#     end
#   end

#   describe 'GET /api/v1/movies/:id' do
#     context 'for non-premium movie' do
#       it 'returns the movie without authentication' do
#         get "/api/v1/movies/#{movie.id}"

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => movie.id, 'title' => movie.title)
#       end
#     end

#     context 'for premium movie without subscription' do
#       it 'returns 403 forbidden' do
#         get "/api/v1/movies/#{premium_movie.id}"

#         expect(response).to have_http_status(:forbidden)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Premium subscription required' })
#       end
#     end

#     context 'for premium movie with subscription' do
#       before do
#         create(:subscription, user: user, status: 'active', plan_type: 'premium')
#       end

#       it 'returns the movie' do
#         get "/api/v1/movies/#{premium_movie.id}", headers: user_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('id' => premium_movie.id, 'title' => premium_movie.title)
#       end
#     end

#     context 'for non-existent movie' do
#       it 'returns 404' do
#         get '/api/v1/movies/999'

#         expect(response).to have_http_status(:not_found)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Movie not found' })
#       end
#     end
#   end

#   describe 'POST /api/v1/movies' do
#     let(:movie_params) do
#       {
#         movie: {
#           title: 'New Movie',
#           genre_id: genre.id,
#           premium: false,
#           release_year: 2020,
#           description: 'A test movie',
#           director: 'Test Director',
#           duration: 120,
#           main_lead: 'Test Actor',
#           streaming_platform: 'Test Platform',
#           rating: 'PG-13' # Added to satisfy potential validation
#         }
#       }
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         post '/api/v1/movies', params: { movie: { title: '', genre_id: genre.id } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         post '/api/v1/movies', params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'PATCH /api/v1/movies/:id' do
#     let(:movie_params) { { movie: { title: 'Updated Movie' } } }

#     context 'with supervisor authentication' do
#       it 'updates the movie and returns 200' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to include('title' => 'Updated Movie')
#       end
#     end

#     context 'with invalid params' do
#       it 'returns 422 with validation errors' do
#         patch "/api/v1/movies/#{movie.id}", params: { movie: { title: '' } }, headers: supervisor_headers

#         expect(response).to have_http_status(422)
#         expect(JSON.parse(response.body)).to include('errors')
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         patch "/api/v1/movies/#{movie.id}", params: movie_params, headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end

#   describe 'DELETE /api/v1/movies/:id' do
#     context 'with supervisor authentication' do
#       it 'deletes the movie and returns 200' do
#         delete "/api/v1/movies/#{movie.id}", headers: supervisor_headers

#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)).to eq({ 'message' => 'Movie deleted successfully' })
#         expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
#       end
#     end

#     context 'with non-supervisor authentication' do
#       it 'returns 401 unauthorized' do
#         delete "/api/v1/movies/#{movie.id}", headers: user_headers

#         expect(response).to have_http_status(:unauthorized)
#         expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
#       end
#     end
#   end
# end

# spec/models/movie_spec.rb
# require 'rails_helper'

# RSpec.describe Movie, type: :model do
#   describe 'associations' do
#     it { should belong_to(:genre).counter_cache(true) }
#     it { should have_many(:watchlists).dependent(:destroy) }
#     it { should have_many(:users).through(:watchlists) }
#     it { should have_one_attached(:poster) }
#     it { should have_one_attached(:banner) }
#   end

#   describe 'validations' do
#     subject { build(:movie) }

#     it { should validate_presence_of(:title) }
#     it { should validate_presence_of(:release_year) }
#     it { should validate_numericality_of(:release_year).only_integer.is_greater_than(1880).is_less_than_or_equal_to(Date.current.year) }

#     it { should validate_presence_of(:rating) }
#     it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10) }

#     it { should validate_presence_of(:genre_id) }
#     it { should validate_presence_of(:director) }
#     it { should validate_presence_of(:duration) }
#     it { should validate_numericality_of(:duration).only_integer.is_greater_than(0) }

#     it { should validate_presence_of(:description) }
#     it { should validate_presence_of(:main_lead) }
#     it { should validate_presence_of(:streaming_platform) }
#     it { should allow_value(true, false).for(:premium) }

#     it 'is invalid with rating below 0' do
#       movie = build(:movie, rating: -1)
#       expect(movie).not_to be_valid
#       expect(movie.errors[:rating]).to include('must be greater than or equal to 0')
#     end

#     it 'is invalid with rating above 10' do
#       movie = build(:movie, rating: 11)
#       expect(movie).not_to be_valid
#       expect(movie.errors[:rating]).to include('must be less than or equal to 10')
#     end

#     it 'is invalid with release_year before 1881' do
#       movie = build(:movie, release_year: 1880)
#       expect(movie).not_to be_valid
#       expect(movie.errors[:release_year]).to include('must be greater than 1880')
#     end

#     it 'is invalid with non-integer duration' do
#       movie = build(:movie, duration: 120.5)
#       expect(movie).not_to be_valid
#       expect(movie.errors[:duration]).to include('must be an integer')
#     end

#     it 'is valid with premium true' do
#       movie = build(:movie, premium: true)
#       expect(movie).to be_valid
#     end
#   end

#   # describe 'watchlists association' do
#   #   let(:genre) { create(:genre) }
#   #   let(:user) { create(:user) }
#   #   let(:movie) { create(:movie, genre: genre) }

#   #   it 'destroys watchlists when movie is destroyed' do
#   #     create(:watchlist, user: user, movie: movie)
#   #     expect { movie.destroy }.to change { Watchlist.count }.by(-1)
#   #   end

#   #   it 'associates users through watchlists' do
#   #     create(:watchlist, user: user, movie: movie)
#   #     expect(movie.users).to include(user)
#   #   end
#   # end

#   describe 'genre association' do
#     let(:genre) { create(:genre) }
#     let(:movie) { create(:movie, genre: genre) }

#     it 'increments genre movies_count' do
#       expect { movie }.to change { genre.reload.movies_count }.by(1)
#     end

#     it 'decrements genre movies_count on destroy' do
#       movie
#       expect { movie.destroy }.to change { genre.reload.movies_count }.by(-1)
#     end
#   end

#   describe '.ransackable_attributes' do
#     it 'returns expected attributes' do
#       expect(Movie.ransackable_attributes).to include('title', 'release_year', 'rating', 'director', 'duration')
#     end
#   end

#   describe '.ransackable_associations' do
#     it 'returns expected associations' do
#       expect(Movie.ransackable_associations).to match_array(%w[subscriptions users genre])
#     end
#   end
# end

# spec/models/movie_spec.rb
require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'associations' do
    it { should belong_to(:genre).counter_cache(true) }
    it { should have_many(:watchlists).dependent(:destroy) }
    it { should have_many(:users).through(:watchlists) }
    it { should have_one_attached(:poster) }
    it { should have_one_attached(:banner) }
  end

  describe 'validations' do
    subject { build(:movie, genre: create(:genre)) } # Ensure genre is set

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:release_year) }
    it { should validate_numericality_of(:release_year).only_integer.is_greater_than(1880).is_less_than_or_equal_to(Date.current.year) }

    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10) }

    it { should validate_presence_of(:genre_id) }
    it { should validate_presence_of(:director) }
    it { should validate_presence_of(:duration) }
    it { should validate_numericality_of(:duration).only_integer.is_greater_than(0) }

    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:main_lead) }
    it { should validate_presence_of(:streaming_platform) }
    it { should allow_value(true, false).for(:premium) }

    it 'is invalid with rating below 0' do
      movie = build(:movie, rating: -1, genre: create(:genre))
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include('must be greater than or equal to 0')
    end

    it 'is invalid with rating above 10' do
      movie = build(:movie, rating: 11, genre: create(:genre))
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include('must be less than or equal to 10')
    end

    it 'is invalid with release_year before 1881' do
      movie = build(:movie, release_year: 1880, genre: create(:genre))
      expect(movie).not_to be_valid
      expect(movie.errors[:release_year]).to include('must be greater than 1880')
    end

    it 'is invalid with non-integer duration' do
      movie = build(:movie, duration: 120.5, genre: create(:genre))
      expect(movie).not_to be_valid
      expect(movie.errors[:duration]).to include('must be an integer')
    end

    it 'is valid with premium true' do
      genre = create(:genre)
      movie = build(:movie, premium: true, genre: genre)
      expect(movie).to be_valid
    end
  end

  describe 'watchlists association' do
    let(:genre) { create(:genre) }
    let(:user) { create(:user) }
    let(:movie) { create(:movie, genre: genre) }

    before do
      # Stub WatchlistNotificationJob to avoid NameError
      allow_any_instance_of(Watchlist).to receive(:send_notification).and_return(nil)
    end

    it 'destroys watchlists when movie is destroyed' do
      create(:watchlist, user: user, movie: movie)
      expect { movie.destroy }.to change { Watchlist.count }.by(-1)
    end

    it 'associates users through watchlists' do
      create(:watchlist, user: user, movie: movie)
      expect(movie.users).to include(user)
    end
  end

  describe 'genre association' do
    let(:genre) { create(:genre) }
    let(:movie) { create(:movie, genre: genre) }

    it 'increments genre movies_count' do
      expect { movie }.to change { genre.reload.movies_count }.by(1)
    end

    it 'decrements genre movies_count on destroy' do
      movie
      expect { movie.destroy }.to change { genre.reload.movies_count }.by(-1)
    end
  end

  describe '.ransackable_attributes' do
    it 'returns expected attributes' do
      expect(Movie.ransackable_attributes).to include('title', 'release_year', 'rating', 'director', 'duration')
    end
  end

  describe '.ransackable_associations' do
    it 'returns expected associations' do
      expect(Movie.ransackable_associations).to match_array(%w[subscriptions users genre])
    end
  end
end