# spec/models/movie_spec.rb
require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'associations' do
    it { should belong_to(:genre).counter_cache(true) }
    it { should have_many(:watchlists).dependent(:destroy) }
    it { should have_many(:users).through(:watchlists) }
    it { should have_one_attached(:poster) }
    it { should have_one_attached(:banner) }
  end

  describe 'validations' do
    subject { build(:movie) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:release_year) }
    it { should validate_numericality_of(:release_year).only_integer.is_greater_than(1880).is_less_than_or_equal_to(Date.current.year) }

    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10) }

    it { should validate_presence_of(:genre_id) }
    it { should validate_presence_of(:director) }
    it { should validate_presence_of(:duration) }
    it { should validate_numericality_of(:duration).only_integer.is_greater_than(0) }

    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:main_lead) }
    it { should validate_presence_of(:streaming_platform) }
    it { should allow_value(true, false).for(:premium) }

    it 'is invalid with rating below 0' do
      movie = build(:movie, rating: -1)
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include('must be greater than or equal to 0')
    end

    it 'is invalid with rating above 10' do
      movie = build(:movie, rating: 11)
      expect(movie).not_to be_valid
      expect(movie.errors[:rating]).to include('must be less than or equal to 10')
    end

    it 'is invalid with release_year before 1881' do
      movie = build(:movie, release_year: 1880)
      expect(movie).not_to be_valid
      expect(movie.errors[:release_year]).to include('must be greater than 1880')
    end

    it 'is invalid with non-integer duration' do
      movie = build(:movie, duration: 120.5)
      expect(movie).not_to be_valid
      expect(movie.errors[:duration]).to include('must be an integer')
    end

    it 'is valid with premium true' do
      movie = build(:movie, premium: true)
      expect(movie).to be_valid
    end
  end

  describe 'watchlists association' do
    let(:genre) { create(:genre) }
    let(:user) { create(:user) }
    let(:movie) { create(:movie, genre: genre) }

    it 'destroys watchlists when movie is destroyed' do
      create(:watchlist, user: user, movie: movie)
      expect { movie.destroy }.to change { Watchlist.count }.by(-1)
    end

    it 'associates users through watchlists' do
      create(:watchlist, user: user, movie: movie)
      expect(movie.users).to include(user)
    end
  end

  describe 'genre association' do
    let(:genre) { create(:genre) }
    let(:movie) { create(:movie, genre: genre) }

    it 'increments genre movies_count' do
      expect { movie }.to change { genre.reload.movies_count }.by(1)
    end

    it 'decrements genre movies_count on destroy' do
      movie
      expect { movie.destroy }.to change { genre.reload.movies_count }.by(-1)
    end
  end

  describe '.ransackable_attributes' do
    it 'returns expected attributes' do
      expect(Movie.ransackable_attributes).to include('title', 'release_year', 'rating', 'director', 'duration')
    end
  end

  describe '.ransackable_associations' do
    it 'returns expected associations' do
      expect(Movie.ransackable_associations).to match_array(%w[subscriptions users genre])
    end
  end
end