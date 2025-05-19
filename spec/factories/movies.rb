FactoryBot.define do
  factory :movie do
    title { Faker::Movie.title }
    genre
    release_year { Faker::Number.between(from: 1900, to: 2025) }
    description { Faker::Lorem.paragraph }
    director { Faker::Name.name }
    duration { Faker::Number.between(from: 60, to: 180) }
    main_lead { Faker::Name.name }
    streaming_platform { 'Test Platform' }
    rating { rand(0.0..10.0).round(1) } # Numerical 0-10
    premium { false }
  end
end