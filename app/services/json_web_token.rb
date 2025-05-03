# class JsonWebToken
#   SECRET_KEY = Rails.application.credentials.secret_key_base

#   def self.encode(payload, exp = 24.hours.from_now)
#     payload[:exp] = exp.to_i
#     JWT.encode(payload, JWT_SECRET_KEY)
#   end

#   def self.decode(token)
#     decoded = JWT.decode(token, JWT_SECRET_KEY)[0]
#     HashWithIndifferentAccess.new(decoded)
#   end
# end
