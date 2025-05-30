# spec/services/stripe_subscription_service_spec.rb
require 'rails_helper'

RSpec.describe StripeSubscriptionService do
  let(:user) { create(:user, email: 'test@example.com') }

  before do
    allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new(id: 'cus_test'))
    allow(Stripe::Customer).to receive(:retrieve).and_return(OpenStruct.new(id: 'cus_test'))
    session_double = double('Stripe::Checkout::Session', id: 'sess_test', url: 'https://stripe.com/session', subscription: 'sub_test', metadata: { 'subscription_id' => 1 }).as_null_object
    allow(session_double).to receive(:is_a?) do |arg|
      arg == Stripe::Checkout::Session || arg == RSpec::Mocks::Double || arg == session_double.class
    end
    allow(Stripe::Checkout::Session).to receive(:create).and_return(session_double)
    allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(session_double)
  end

  before(:each) do
    user.subscriptions.destroy_all
  end

  describe '.create_checkout_session' do
    context 'with basic plan' do
      it 'creates an active subscription' do
        allow_any_instance_of(Subscription).to receive(:requires_end_date?).and_return(false)
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
        expect(result.subscription.plan_type).to eq('premium')
        expect(result.subscription.status).to eq('pending')
      end
    end
  end
end
