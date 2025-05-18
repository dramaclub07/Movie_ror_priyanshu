FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    name { Faker::Name.name }
    role { 'user' }
    phone_number { "9#{Faker::Number.number(digits: 9)}" } # Valid Indian phone number

    trait :admin do
      role { "admin" }
    end

    trait :supervisor do
      role { "supervisor" }
    end

    trait :with_otp do
      otp { "123456" }
      otp_expires_at { 10.minutes.from_now }
    end

    trait :invalid_email do
      email { "not-an-email" }
    end

    trait :short_password do
      password { "123" }
      password_confirmation { "123" }
    end

    trait :missing_name do
      name { nil }
    end
  end
end
