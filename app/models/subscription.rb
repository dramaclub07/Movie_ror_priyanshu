class Subscription < ApplicationRecord
  belongs_to :user

  validates :status, presence: true, inclusion: {
    in: %w[pending active cancelled],
    message: '%<value>s is not a valid status'
  }

  validates :plan_type, presence: true,
                        inclusion: { in: %w[basic premium], message: '%<value>s is not a valid plan type' }

  validates :start_date, presence: true
  validates :end_date, presence: true, if: :requires_end_date?
  validate :end_date_after_start_date, if: -> { end_date.present? }

  scope :active, -> { where(status: 'active') }
  scope :premium, -> { where(plan_type: 'premium') }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id plan_type status start_date end_date stripe_customer_id stripe_subscription_id user_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  private

  def requires_end_date?
    status == 'cancelled' || (plan_type == 'basic' && status != 'pending')
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end
end
