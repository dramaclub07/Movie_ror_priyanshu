require 'rails_helper'

RSpec.describe BlacklistedToken, type: :model do
  describe 'validations' do
    subject { create(:blacklisted_token) }

    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
    it { should validate_presence_of(:expires_at) }
  end

  describe '.cleanup' do
    let!(:expired_token) { create(:blacklisted_token, expires_at: 1.day.ago) }
    let!(:valid_token) { create(:blacklisted_token, expires_at: 1.day.from_now) }

    it 'removes expired tokens' do
      expect {
        BlacklistedToken.cleanup
      }.to change(BlacklistedToken, :count).by(-1)

      expect(BlacklistedToken.find_by(id: expired_token.id)).to be_nil
      expect(BlacklistedToken.find_by(id: valid_token.id)).to be_present
    end
  end
end