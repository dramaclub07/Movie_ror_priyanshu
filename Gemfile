# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.4'

# Rails framework
gem 'rails', '~> 7.1.5'

# Database
gem 'pg', '~> 1.5'

# Authentication
gem 'bcrypt', '~> 3.1.7'
gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.11'
gem 'jwt', '~> 2.8'
gem 'omniauth', '~> 2.1'
gem 'omniauth-google-oauth2', '~> 1.1'

# API and serialization
gem 'active_model_serializers', '~> 0.10'
gem 'jbuilder', '~> 2.12'
gem 'rswag', '~> 2.16'
gem 'rswag-api', '~> 2.16'
gem 'rswag-specs', '~> 2.16'
gem 'rswag-ui', '~> 2.16'

# Admin interface
gem 'activeadmin', '~> 3.2'

# Authorization
gem 'cancancan', '~> 3.6'

# File storage
gem 'activestorage', '~> 7.1'
gem 'cloudinary', '~> 1.28'

# Phone number validation
gem 'phonelib', '~> 0.8'

# Web server
gem 'puma', '~> 6.4'

# Asset management
gem 'importmap-rails', '~> 2.0'
gem 'sassc-rails', '~> 2.1'
gem 'sprockets-rails', '~> 3.5'
gem 'stimulus-rails', '~> 1.3'
gem 'turbo-rails', '~> 2.0'

# Performance
gem 'bootsnap', '~> 1.18', require: false

# Environment variables
gem 'dotenv-rails', '~> 3.1'

# HTTP requests
gem 'googleauth', '~> 1.11'
gem 'httparty', '~> 0.22'

# Payment processing
gem 'stripe', '~> 12.0'

# SMS integration
gem 'twilio-ruby', '~> 7.2'

# CORS
gem 'rack-cors', '~> 2.0'

# Deployment
gem 'kamal', '~> 2.0', require: false
gem 'thruster', '~> 0.1', require: false

# Timezone data for Windows
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', '~> 6.1', require: false
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'debug', '~> 1.9', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.4'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '~> 1.64', require: false
  gem 'rubocop-rails-omakase', '~> 1.0', require: false
  gem 'shoulda-matchers', '~> 6.2'
end

group :development do
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.23'
  gem 'simplecov', '~> 0.22', require: false
end
