module JsonHelper
  def json
    JSON.parse(response.body)
  end

  def auth_headers_for(user)
    token = generate_jwt_token(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  private

  def generate_jwt_token(user)
    payload = { user_id: user.id, email: user.email, role: user.role, exp: 24.hours.from_now.to_i }
    secret = ENV['JWT_SECRET_KEY'] || Rails.application.credentials.jwt_secret_key
    JWT.encode(payload, secret, 'HS256')
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
end