FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Password123' }
    password_confirmation { 'Password123' }
    phone_number { "#{[6, 7, 8, 9].sample}#{Faker::Number.number(digits: 9)}" } # e.g., "6789012345"
    name { Faker::Name.name }
    role { 'user' }
  end
end