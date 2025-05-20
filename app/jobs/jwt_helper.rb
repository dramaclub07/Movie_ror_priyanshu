module JwtHelper
  def generate_jwt_token(user)
    JwtService.generate_tokens(user.id)[:access_token]
  end
end

RSpec.configure do |config|
  config.include JwtHelper
end