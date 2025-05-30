Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'email,profile',
    access_type: 'online'
  }
end

# Remove the path prefix setting as it's causing conflicts
# OmniAuth.config.path_prefix = '/users/auth'
