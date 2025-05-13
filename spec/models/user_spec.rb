# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    subject { create(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:phone_number) }
    it { should validate_uniqueness_of(:phone_number).case_insensitive }
    it {
      should allow_value('9876543210')
        .for(:phone_number)
    }
  end

  describe 'Enums' do
    it {
      should define_enum_for(:role)
        .with_values(user: 'user', supervisor: 'supervisor')
        .backed_by_column_of_type(:string)
    }
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          name: 'Test User'
        }
      )
    end

    it 'creates a user from omniauth' do
      user = User.from_omniauth(auth)
      expect(user).to be_persisted
      expect(user.email).to eq('test@example.com')
    end
  end

  describe '#generate_otp' do
    it 'generates a 6-digit otp and sets expiry' do
      user = create(:user)
      otp = user.generate_otp
      expect(otp.to_s.length).to eq(6)
      expect(user.otp).to eq(otp.to_s)
      expect(user.otp_expires_at).to be > Time.now
    end
  end

  describe '#verify_otp' do
    it 'returns true for correct and valid otp' do
      user = create(:user)
      otp = user.generate_otp
      expect(user.verify_otp(otp.to_s)).to be true
    end

    it 'returns false for incorrect otp' do
      user = create(:user)
      user.generate_otp
      expect(user.verify_otp('000000')).to be false
    end

    it 'returns false for expired otp' do
      user = create(:user, otp: '654321', otp_expires_at: 1.minute.ago)
      expect(user.verify_otp('654321')).to be false
    end
  end
end
