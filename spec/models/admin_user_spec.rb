require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'devise modules' do
    it 'should include default devise modules' do
      expect(AdminUser.devise_modules).to contain_exactly(
        :database_authenticatable,
        :recoverable,
        :rememberable,
        :validatable
      )
    end
  end

  describe 'roles' do
    let(:admin_user) { create(:admin_user) }

    it 'has a default role of admin' do
      expect(admin_user.role).to eq('admin')
    end
  end
end