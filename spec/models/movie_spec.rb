# spec/models/movie_spec.rb

require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'associations' do
    it { should belong_to(:genre).counter_cache(true) }
    it { should have_many(:subscriptions) }
    it { should have_many(:users).through(:subscriptions) }
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
  end

  describe 'custom validations' do
    let(:movie) { build(:movie) }

    context 'poster content type' do
      it 'is valid with jpeg/png' do
        movie.poster.attach(io: File.open(Rails.root.join('spec/fixtures/files/poster.jpg')),
                            filename: 'poster.jpg', content_type: 'image/jpeg')
        expect(movie).to be_valid
      end

      it 'is invalid with non-image content type' do
        movie.poster.attach(io: File.open(Rails.root.join('spec/fixtures/files/fake.txt')),
                            filename: 'fake.txt', content_type: 'text/plain')
        expect(movie).not_to be_valid
        expect(movie.errors[:poster]).to include('must be a JPEG or PNG')
      end
    end

    context 'banner content type' do
      it 'is valid with jpeg/png' do
        movie.banner.attach(io: File.open(Rails.root.join('spec/fixtures/files/banner.png')),
                            filename: 'banner.png', content_type: 'image/png')
        expect(movie).to be_valid
      end

      it 'is invalid with wrong file type' do
        movie.banner.attach(io: File.open(Rails.root.join('spec/fixtures/files/fake.txt')),
                            filename: 'fake.txt', content_type: 'text/plain')
        expect(movie).not_to be_valid
        expect(movie.errors[:banner]).to include('must be a JPEG or PNG')
      end
    end
  end

  describe 'scopes' do
    before do
      @with_poster = create(:movie, :with_poster)
      @without_poster = create(:movie)
      @with_banner = create(:movie, :with_banner)
      @without_banner = create(:movie)
    end

    it 'returns movies with posters' do
      expect(Movie.with_poster).to include(@with_poster)
      expect(Movie.with_poster).not_to include(@without_poster)
    end

    it 'returns movies without posters' do
      expect(Movie.without_poster).to include(@without_poster)
      expect(Movie.without_poster).not_to include(@with_poster)
    end

    it 'returns movies with banners' do
      expect(Movie.with_banner).to include(@with_banner)
      expect(Movie.with_banner).not_to include(@without_banner)
    end

    it 'returns movies without banners' do
      expect(Movie.without_banner).to include(@without_banner)
      expect(Movie.without_banner).not_to include(@with_banner)
    end
  end

  describe '#poster_url' do
    it 'returns poster URL if attached' do
      movie = create(:movie, :with_poster)
      expect(movie.poster_url).to be_present
    end

    it 'returns nil if not attached' do
      movie = create(:movie)
      expect(movie.poster_url).to be_nil
    end
  end

  describe '#banner_url' do
    it 'returns banner URL if attached' do
      movie = create(:movie, :with_banner)
      expect(movie.banner_url).to be_present
    end

    it 'returns nil if not attached' do
      movie = create(:movie)
      expect(movie.banner_url).to be_nil
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
