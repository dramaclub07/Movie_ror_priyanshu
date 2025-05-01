class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base
  ALGORITHM = 'HS256'

  def self.generate_tokens(user_id)
    access_payload = { user_id: user_id, exp: 15.minutes.from_now.to_i }
    refresh_payload = { user_id: user_id, exp: 1.month.from_now.to_i }

    {
      access_token: encode(access_payload),
      refresh_token: encode(refresh_payload)
    }
  end

  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError
    nil
  end

  def self.authenticate_token(token)
    decoded = decode(token)
    return nil unless decoded

    User.find_by(id: decoded[:user_id])
  end

  def self.rotate_refresh_token(user_id)
    payload = { user_id: user_id, exp: 1.month.from_now.to_i }
    new_refresh_token = encode(payload)
    User.find_by(id: user_id)&.update(refresh_token: new_refresh_token)
    { refresh_token: new_refresh_token }
  end

  def self.invalidate_refresh_token(user_id)
    User.find_by(id: user_id)&.update(refresh_token: nil)
  end

  def self.refresh_token_expired?(token)
    decoded = decode(token)
    return true unless decoded

    decoded[:exp] < Time.now.to_i
  end

  def self.verify_refresh_token(token)
    return nil if refresh_token_expired?(token)

    decoded = decode(token)
    return nil unless decoded

    user = User.find_by(id: decoded[:user_id])
    user if user && user.refresh_token == token
  end
end
