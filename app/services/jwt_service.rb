class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret_key || Rails.application.credentials.secret_key_base

  ALGORITHM = 'HS256'
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 1.month

  # Generates both access and refresh tokens along with their expiry times
  def self.generate_tokens(user_id)
    access_expiry = ACCESS_TOKEN_EXPIRY.from_now
    refresh_expiry = REFRESH_TOKEN_EXPIRY.from_now

    access_payload = { user_id: user_id, exp: access_expiry.to_i }
    refresh_payload = { user_id: user_id, exp: refresh_expiry.to_i }

    {
      access_token: encode(access_payload),
      refresh_token: encode(refresh_payload),
      access_token_expiry: access_expiry,
      refresh_token_expiry: refresh_expiry
    }
  end

  # Encodes the payload into a JWT token
  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  # Decodes the JWT token and returns the decoded payload
  def self.decode(token)
    Rails.logger.debug("Decoding token: #{token}") if Rails.env.development?
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    Rails.logger.debug("Decoded payload: #{decoded}") if Rails.env.development?
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    Rails.logger.warn('JWT expired')
    nil
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT decode failed: #{e.message}")
    nil
  rescue JWT::VerificationError => e
    Rails.logger.error("JWT verification failed: #{e.message}")
    nil
  end

  # Authenticates the token by decoding it and returning the user object
  def self.authenticate_token(token)
    decoded = decode(token)
    return nil unless decoded

    User.find_by(id: decoded[:user_id])
  end

  # Rotates the refresh token, creating a new one and updating the user's refresh_token
  def self.rotate_refresh_token(user_id)
    payload = { user_id: user_id, exp: REFRESH_TOKEN_EXPIRY.from_now.to_i }
    new_refresh_token = encode(payload)
    user = User.find_by(id: user_id)
    user.update(refresh_token: new_refresh_token) if user
    { refresh_token: new_refresh_token }
  end

  # Invalidates the user's refresh token
  def self.invalidate_refresh_token(user_id)
    user = User.find_by(id: user_id)
    user.update(refresh_token: nil) if user
  end

  # Checks if the refresh token has expired
  def self.refresh_token_expired?(token)
    decoded = decode(token)
    return true unless decoded

    decoded[:exp] < Time.now.to_i
  end

  # Verifies the refresh token and ensures it is not expired and matches the stored token
  def self.verify_refresh_token(token)
    return nil if refresh_token_expired?(token)

    decoded = decode(token)
    return nil unless decoded

    user = User.find_by(id: decoded[:user_id])
    user if user && user.refresh_token == token
  end
end
