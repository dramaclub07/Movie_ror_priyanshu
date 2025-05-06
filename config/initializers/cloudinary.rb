Cloudinary.config do |config|
  creds = Rails.application.credentials.cloudinary
  config.cloud_name = creds[:cloud_name]
  config.api_key = creds[:api_key]
  config.api_secret = creds[:api_secret]
  config.secure = true
end
