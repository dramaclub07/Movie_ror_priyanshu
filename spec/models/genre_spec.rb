# spec/models/genre_spec.rb
require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:movies).dependent(:destroy) }
  end

  it 'is valid with a name' do
    genre = build(:genre, name: 'Action')
    expect(genre).to be_valid
  end

  it 'is invalid without a name' do
    genre = build(:genre, name: nil)
    expect(genre).not_to be_valid
  end
  
  it 'is invalid with a duplicate name' do
    create(:genre, name: 'UniqueGenre')
    genre = build(:genre, name: 'UniqueGenre')
    expect(genre).not_to be_valid
  end

  it 'has many movies' do
    genre = create(:genre)
    movie1 = create(:movie, genre: genre)
    movie2 = create(:movie, genre: genre)
    expect(genre.movies).to include(movie1, movie2)
  end

  describe '.ransackable_attributes' do
    it 'returns expected attributes' do
      expect(Genre.ransackable_attributes).to include('name')
    end
  end

  describe '.ransackable_associations' do
    it 'returns expected associations' do
      expect(Genre.ransackable_associations).to include('movies')
    end
  end
end