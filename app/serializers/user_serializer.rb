class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone_number, :name, :role, :created_at, :updated_at, :plan_type

  def plan_type
    object.subscriptions
          .where(status: 'active')
          .order(created_at: :desc)
          .limit(1)
          .pluck(:plan_type)
          .first
  end
end
