# Minimal Rswag UI initializer compatible with current version
Rswag::Ui.configure do |c|
  # Specify the OpenAPI/Swagger docs to display in the UI
  c.config_object[:urls] = [
    { url: '/api-docs/v1/swagger.yaml', name: 'API V1 Docs' }
  ]
  # Add more config here if needed for your version
end
