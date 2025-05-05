# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Movie Explorer API V1',
        version: 'v1',
        description: 'Movie Explorer API documentation'
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          },
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: 'access_token'
          }
        },
        schemas: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              phone_number: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[email phone_number password password_confirmation]
          },
          movie: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              release_year: { type: :integer },
              rating: { type: :string },
              genre_id: { type: :integer },
              poster: { type: :string, format: 'binary' }
            },
            required: %w[title release_year rating genre_id]
          },
          genre: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string }
            },
            required: ['name']
          },
          subscription: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              plan_type: { type: :string, enum: %w[basic premium] },
              status: { type: :string, enum: %w[active inactive] }
            },
            required: %w[plan_type]
          }
        }
      },
      security: [
        { bearerAuth: [], cookieAuth: [] }
      ],
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
