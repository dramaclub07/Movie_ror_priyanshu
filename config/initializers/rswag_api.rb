# frozen_string_literal: true

# Configure Rswag API.
Rswag::Api.configure do |c|
  # Specify a root folder where OpenAPI/Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.openapi_root = "#{Rails.root}/swagger"

  # Remove any unsupported endpoint configuration for your rswag version
  # If you need to customize the filter, you can uncomment and edit the following:
  # c.openapi_filter = lambda { |openapi, env| openapi['host'] = env['HTTP_HOST'] }
end
