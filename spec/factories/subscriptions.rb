FactoryBot.define do
  factory :subscription do
    user
    plan_type { 'basic' }
    status { 'active' }
    stripe_subscription_id { "sub_#{SecureRandom.hex(10)}" }
    start_date { Time.current }
    end_date { 1.month.from_now }
  end
end