# spec/models/watchlist_spec.rb
require 'rails_helper'

RSpec.describe Watchlist, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:movie) }
  end

  describe 'validations' do
    it 'is valid with user and movie' do
      watchlist = build(:watchlist)
      expect(watchlist).to be_valid
    end

    it 'is invalid without user' do
      watchlist = build(:watchlist, user: nil)
      expect(watchlist).not_to be_valid
    end
  end
end