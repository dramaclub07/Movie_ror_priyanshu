# spec/factories/genres.rb
FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "Genre#{n}-#{Faker::Book.genre}" }
  end
end