class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :plan_type, :status, :start_date, :end_date, :created_at, :updated_at
end
