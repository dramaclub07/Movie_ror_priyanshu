require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Movie Explorer API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Local development server'
        },
        {
          url: 'https://movie-ror-priyanshu-singh.onrender.com',
          description: 'Production server on Render'
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      }
    }
  }

  # Global security requirement is commented out to prevent automatic Authorization header
  # Individual endpoints specify security as needed (e.g., logout uses bearer_auth)
  # config.openapi_specs['v1/swagger.yaml'][:security] = [{ bearer_auth: [] }]

  config.openapi_format = :yaml
end