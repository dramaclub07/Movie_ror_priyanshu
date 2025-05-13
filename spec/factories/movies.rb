FactoryBot.define do
  factory :movie do
    title { "Example Movie" }
    release_year { 2022 }
    rating { 8.5 }
    association :genre # Ensures genre_id is set
    director { "Famous Director" }
    duration { 120 }
    description { "An exciting movie about testing." }
    main_lead { "Lead Actor" }
    streaming_platform { "Netflux" }
    premium { false }

    trait :with_poster do
      after(:build) do |movie|
        movie.poster.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'poster.jpg')),
          filename: 'poster.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_banner do
      after(:build) do |movie|
        movie.banner.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'banner.jpg')),
          filename: 'banner.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end