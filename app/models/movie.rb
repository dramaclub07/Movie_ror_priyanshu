class Movie < ApplicationRecord
  has_many :subscriptions
  has_many :users, through: :subscriptions
  belongs_to :genre

  has_one_attached :poster

  validates :title, presence: true
  validates :release_year, presence: true, numericality: { only_integer: true, greater_than: 1888 }
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :genre_id, presence: true

  # Custom validation for poster content type
  validate :poster_content_type, if: :poster_attached?

  def poster_url
    Rails.application.routes.url_helpers.url_for(poster) if poster.attached?
  end

  private

  def poster_attached?
    poster.attached?
  end

  def poster_content_type
    return unless poster.attached?

    unless poster.blob.content_type.in?(%w[image/jpeg image/png])
      errors.add(:poster, 'must be a JPEG or PNG')
    end
  end
end