class Subscription < ApplicationRecord
  belongs_to :user

  validates :status, presence: true, inclusion: {
    in: %w[pending active cancelled],
    message: '%<value>s is not a valid status'
  }

  validates :plan_type, presence: true,
                        inclusion: { in: %w[basic premium], message: '%<value>s is not a valid plan type' }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  def self.ransackable_attributes(auth_object = nil)
    %w[id plan_type status start_date end_date user_id  created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end
end
