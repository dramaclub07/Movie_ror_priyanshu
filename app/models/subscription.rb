class Subscription < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :movie

  scope :active, -> { where('end_date > ?', Time.current) }

  # Validations
  validates :plan_type, presence: true,
                        inclusion: { in: %w[basic premium], message: '%<value>s is not a valid plan type' }
  validates :status, presence: true, inclusion: { in: %w[active inactive], message: '%<value>s is not a valid status' }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    return unless end_date < start_date

    errors.add(:end_date, 'must be after start date')
  end
end
