FactoryBot.define do
  factory :blacklisted_token do
    sequence(:token) { |n| "token_#{n}" }
    expires_at { 1.day.from_now }
  end
end