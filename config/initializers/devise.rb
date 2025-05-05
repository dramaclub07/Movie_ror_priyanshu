# frozen_string_literal: true

require 'omniauth-google-oauth2'

Devise.setup do |config|
  # Mailer
  config.mailer_sender = ENV['DEVISE_MAILER_SENDER'] || 'please-change-me@example.com'
  # config.mailer = 'Devise::Mailer'
  # config.parent_mailer = 'ActionMailer::Base'

  # ORM
  require 'devise/orm/active_record'

  # Authentication keys
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.authentication_keys = [:email]

  # Parameters and sessions
  config.skip_session_storage = [:http_auth]
  config.navigational_formats = [] # Important for API-only apps

  # Password configuration
  config.stretches = Rails.env.test? ? 1 : 12
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  # config.pepper = 'your-pepper-here' # Optional, for added security

  # Confirmable and reconfirmable
  config.reconfirmable = true
  # config.allow_unconfirmed_access_for = 0.days
  # config.confirm_within = 3.days

  # Timeoutable (optional)
  # config.timeout_in = 30.minutes

  # Rememberable
  config.expire_all_remember_me_on_sign_out = true

  # Reset password
  config.reset_password_within = 6.hours
  # config.sign_in_after_reset_password = true

  # Sign out via
  config.sign_out_via = :delete

  # Omniauth - Google OAuth2
  config.omniauth :google_oauth2,
                  ENV['GOOGLE_CLIENT_ID'],
                  ENV['GOOGLE_CLIENT_SECRET'],
                  scope: 'email,profile',
                  access_type: 'online'

  # API authentication (optional)
  # config.http_authenticatable = [:database]
  # config.params_authenticatable = true
  # config.clean_up_csrf_token_on_authentication = true

  # Notifications (optional)
  # config.send_email_changed_notification = true
  # config.send_password_change_notification = true

  # Secret key (optional)
  # config.secret_key = ENV['DEVISE_SECRET_KEY']
end
