# frozen_string_literal: true

FactoryBot.define do
  factory :blacklisted_token do
    token { 'MyString' }
    user_id { 1 }
    expires_at { '2025-05-08 11:37:19' }
  end
end
