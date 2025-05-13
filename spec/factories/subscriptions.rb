# spec/factories/subscriptions.rb
FactoryBot.define do
  factory :subscription do
    user                           
    plan_type { 'basic' }           
    status { 'active' }             
    start_date { Date.today }
    end_date { Date.today + 1.month }
  end
end
