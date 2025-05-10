# spec/services/stripe_subscription_service_spec.rb
require 'rails_helper'

RSpec.describe StripeSubscriptionService do
  let(:user) { create(:user, email: 'test@example.com') }

  describe '.create_checkout_session' do
    context 'with basic plan' do
      it 'creates an active subscription' do
        result = described_class.create_checkout_session(user: user, plan: 'basic')
        expect(result.success?).to be true
        expect(result.subscription.plan_type).to eq('basic')
        expect(result.subscription.status).to eq('active')
        expect(result.subscription.end_date).to be_nil
      end
    end

    context 'with premium plan' do
      it 'creates a pending subscription and Stripe session' do
        result = described_class.create_checkout_session(user: user, plan: 'premium')
        expect(result.success?).to be true
        expect(result.session).to be_a(Stripe::Checkout::Session)
        expect(result.subscription.plan_type).to eq('premium')
        expect(result.subscription.status).to eq('pending')
      end
    end
  end
end