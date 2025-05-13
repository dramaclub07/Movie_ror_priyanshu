FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    phone_number { "9#{Faker::Number.number(digits: 9)}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "user" }

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
