require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'simplecov'
require 'database_cleaner/active_record'
require 'factory_bot_rails'
require 'rswag/specs'

# Configure SimpleCov
SimpleCov.start 'rails' do
  enable_coverage :branch
  
  # Coverage groups
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
  add_group 'Mailers', 'app/mailers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Policies', 'app/policies'
  add_group 'Serializers', 'app/serializers'
  
  # Filters
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/spec/'
  add_filter '/db/'
  
  # Coverage thresholds
  minimum_coverage line: 80
  minimum_coverage_by_file line: 70
end

abort("The Rails environment is running in production mode!") if Rails.env.production?

# Load support files
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# Configure Active Storage for tests
Rails.application.routes.default_url_options[:host] = 'localhost:3000'

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.fixture_path = Rails.root.join('spec/fixtures')

  # Factory Bot setup
  config.include FactoryBot::Syntax::Methods

  # Database cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    
    # Set URL options for ActiveStorage
    ActiveStorage::Current.url_options = { host: 'localhost:3000' }
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
    ActiveStorage::Current.url_options = { host: 'localhost:3000' }
    # Configure Active Job to use test adapter
    ActiveJob::Base.queue_adapter = :test
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Include helpers
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers

  # Include JSON helpers
  config.include JsonHelper, type: :request

  # Include Auth helpers
  config.include AuthHelper, type: :request

  # Include Request helpers
  config.include RequestHelper, type: :request

  # Configure JWT token settings
  config.before(:each, type: :request) do
    @jwt_token = nil
  end

  # Default headers for request specs
  config.before(:each, type: :request) do |example|
    host! 'localhost:3000'
    if example.metadata[:swagger]
      default_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      default_headers.each { |key, value| header key, value }
    end
  end

  # RSpec settings
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.order = :random
  config.example_status_persistence_file_path = "tmp/examples.txt"

  # Swagger configuration
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Movies API',
        version: 'v1'
      },
      components: {
        schemas: {
          movie: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              release_year: { type: :integer },
              genre_id: { type: :integer },
              premium: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['title', 'genre_id']
          },
          error: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          }
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      },
      security: [{ bearer_auth: [] }],
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'movie-ror-priyanshu-singh.onrender.com'
            }
          }
        }
      ]
    }
  }

  config.before(:each, type: :request) do |example|
    if example.metadata[:swagger]
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
    end
  end
end

# Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end