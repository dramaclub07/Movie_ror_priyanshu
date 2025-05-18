FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Example Movie #{n}" }
    sequence(:release_year) { |n| 2020 + (n % 5) }
    sequence(:rating) { |n| [7.5, 8.0, 8.5, 9.0, 9.5][n % 5] }
    association :genre, strategy: :create
    sequence(:director) { |n| "Director #{n}" }
    sequence(:duration) { |n| 90 + (n * 10) }
    sequence(:description) { |n| "An exciting movie about testing #{n}." }
    sequence(:main_lead) { |n| "Actor #{n}" }
    sequence(:streaming_platform) { |n| ["Netflix", "Prime", "Hulu", "Disney+", "HBO"][n % 5] }
    premium { [true, false].sample }

    trait :with_poster do
      after(:build) do |movie|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'poster.png')
        movie.poster.attach(
          io: File.open(file_path),
          filename: "poster_#{Time.current.to_i}.png",
          content_type: 'image/png'
        )
      end
    end

    trait :with_banner do
      after(:build) do |movie|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'banner.png')
        movie.banner.attach(
          io: File.open(file_path),
          filename: "banner_#{Time.current.to_i}.png",
          content_type: 'image/png'
        )
      end
    end
  end
end