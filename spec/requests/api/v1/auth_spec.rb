require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  let(:password) { 'password123' }
  let(:user) do
    create(:user,
           email: 'user90@example.com',
           password: password,
           password_confirmation: password,
           phone_number: '9876843210',
           name: 'Priyanshu Dev')
  end

  describe 'POST /api/v1/register' do
    it 'creates a user with valid attributes' do
      valid_attrs = attributes_for(:user).merge(password: 'securepass', password_confirmation: 'securepass')

      post '/api/v1/register', params: { user: valid_attrs }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['message']).to eq('User registered successfully')
      expect(response.parsed_body['user']['email']).to eq(valid_attrs[:email])
    end

    it 'returns error for duplicate email' do
      create(:user, email: 'dupe@example.com')

      post '/api/v1/register', params: { user: { email: 'dupe@example.com', password: '123456', password_confirmation: '123456', phone_number: '9876543211', name: 'Dupe' } }, as: :json

      expect(response).to have_http_status(422)
      expect(response.parsed_body['errors']).to include('Email has already been taken')
    end
  end

  describe 'POST /api/v1/login' do
    it 'logs in with correct credentials' do
      user # ensure user is created
      post '/api/v1/login', params: { user: { email: user.email, password: password } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('User logged in successfully')
      expect(response.parsed_body['auth_info']['access_token']).to be_present
    end

    it 'rejects invalid password' do
      post '/api/v1/login', params: { user: { email: user.email, password: 'wrongpass' } }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Invalid credentials')
    end
  end

  describe 'POST /api/v1/refresh-token' do
    it 'refreshes token if valid refresh token is provided' do
      tokens = JwtService.generate_tokens(user.id)
      user.update!(refresh_token: tokens[:refresh_token])
      cookies[:refresh_token] = tokens[:refresh_token]

      post '/api/v1/refresh-token', as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['auth_info']['refresh_token']['token']).to be_present
    end

    it 'returns 401 for invalid refresh token' do
      cookies[:refresh_token] = 'invalid-token'

      post '/api/v1/refresh-token', as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Invalid refresh token')
    end
  end

  describe 'DELETE /api/v1/logout' do
    it 'logs out and clears tokens' do
      tokens = JwtService.generate_tokens(user.id)
      user.update!(refresh_token: tokens[:refresh_token])
      cookies[:access_token] = tokens[:access_token]
      cookies[:refresh_token] = tokens[:refresh_token]

      delete '/api/v1/logout', headers: { 'Authorization' => "Bearer #{tokens[:access_token]}" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Successfully signed out')
      expect(response.parsed_body['auth_info']['status']).to eq('logged_out')
    end
  end

  describe 'POST /api/v1/google' do
    it 'authenticates user via Google (mocked)' do
      stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
        .to_return(status: 200, body: {
          sub: '12345',
          email: 'googleuser@example.com',
          name: 'Google User'
        }.to_json, headers: { 'Content-Type' => 'application/json' })

      allow(OAuth2::AccessToken).to receive(:new).and_return(
        instance_double(OAuth2::AccessToken, get: OpenStruct.new(body: {
          sub: '12345',
          email: 'googleuser@example.com',
          name: 'Google User'
        }.to_json))
      )

      post '/api/v1/google', params: { access_token: 'valid-google-token' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['user']['email']).to eq('googleuser@example.com')
    end

    it 'returns 401 for invalid Google token' do
      post '/api/v1/google', params: { access_token: nil }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Invalid Google token')
    end
  end
end
