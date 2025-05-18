require 'rails_helper'

RSpec.describe Watchlist, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:movie) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:movie) { create(:movie) }
    
    it 'validates uniqueness of movie per user' do
      create(:watchlist, user: user, movie: movie)
      duplicate_watchlist = build(:watchlist, user: user, movie: movie)
      expect(duplicate_watchlist).not_to be_valid
      expect(duplicate_watchlist.errors[:movie_id]).to include('has already been added to watchlist')
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:movies) { create_list(:movie, 3) }
    
    before do
      movies.each do |movie|
        create(:watchlist, user: user, movie: movie)
      end
    end

    it '.for_user returns watchlist items for specific user' do
      other_user = create(:user)
      other_watchlist = create(:watchlist, user: other_user, movie: create(:movie))
      
      expect(Watchlist.for_user(user).count).to eq(3)
      expect(Watchlist.for_user(user)).not_to include(other_watchlist)
    end
  end

  describe 'callbacks' do
    it 'sends notification after creation' do
      user = create(:user)
      movie = create(:movie)
      
      expect {
        create(:watchlist, user: user, movie: movie)
      }.to have_enqueued_job(WatchlistNotificationJob)
    end
  end
end
