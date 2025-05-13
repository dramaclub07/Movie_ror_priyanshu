require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with all valid attributes' do
      subscription = build(:subscription, user: user)
      expect(subscription).to be_valid
    end

    it 'is invalid without a status' do
      subscription = build(:subscription, user: user, status: nil)
      expect(subscription).to be_invalid
      expect(subscription.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with an unknown status' do
      subscription = build(:subscription, user: user, status: 'unknown')
      expect(subscription).to be_invalid
    end

    it 'is invalid without a plan_type' do
      subscription = build(:subscription, user: user, plan_type: nil)
      expect(subscription).to be_invalid
    end

    it 'is invalid with an invalid plan_type' do
      subscription = build(:subscription, user: user, plan_type: 'gold')
      expect(subscription).to be_invalid
    end

    it 'requires end_date if status is cancelled' do
      subscription = build(:subscription, user: user, status: 'cancelled', end_date: nil)
      expect(subscription).to be_invalid
    end

    it 'requires end_date if plan is basic and not pending' do
      subscription = build(:subscription, user: user, plan_type: 'basic', status: 'active', end_date: nil)
      expect(subscription).to be_invalid
    end

    it 'does not require end_date if plan is premium and status is active' do
      subscription = build(:subscription, user: user, plan_type: 'premium', status: 'active', end_date: nil)
      expect(subscription).to be_valid
    end

    it 'is invalid if end_date is before start_date' do
      subscription = build(:subscription, user: user, start_date: Date.today, end_date: Date.yesterday)
      expect(subscription).to be_invalid
      expect(subscription.errors[:end_date]).to include('must be after start date')
    end
  end

  describe 'scopes' do
    before do
      @active = create(:subscription, user: user, status: 'active')
      @cancelled = create(:subscription, user: user, status: 'cancelled', end_date: Date.today)
      @premium = create(:subscription, user: user, plan_type: 'premium')
    end

    it 'returns only active subscriptions' do
      expect(Subscription.active).to include(@active)
      expect(Subscription.active).not_to include(@cancelled)
    end

    it 'returns only premium subscriptions' do
      expect(Subscription.premium).to include(@premium)
      expect(Subscription.premium).not_to include(@cancelled)
    end
  end
end
