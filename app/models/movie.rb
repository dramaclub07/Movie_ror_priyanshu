class Movie < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_many :subscriptions
  has_many :users, through: :subscriptions
  belongs_to :genre, counter_cache: true

  has_one_attached :poster
  has_one_attached :banner
  has_many :watchlists, dependent: :destroy
  has_many :users, through: :watchlists

  validates :title, presence: true
  validates :release_year, presence: true,
                           numericality: { only_integer: true, greater_than: 1880, less_than_or_equal_to: Date.current.year }
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :genre_id, presence: true
  validates :director, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :description, presence: true
  validates :main_lead, presence: true
  validates :streaming_platform, presence: true
  validates :premium, inclusion: { in: [true, false] }

  validate :poster_content_type, if: :poster_attached?
  validate :banner_content_type, if: :banner_attached?
  validates :trailer, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Scopes for filtering by poster and banner presence
  scope :with_poster, -> { where.associated(:poster_attachment) }
  scope :without_poster, -> { where.missing(:poster_attachment) }
  scope :with_banner, -> { where.associated(:banner_attachment) }
  scope :without_banner, -> { where.missing(:banner_attachment) }


  def poster_url
    return unless poster.attached?
    blob = poster.blob
    return unless blob&.key.present? &&
                blob.filename.present? &&
                blob.content_type.present?
    poster.service.url(blob.key, eager: true)
  rescue ArgumentError => e
    Rails.logger.warn("Poster URL error for Movie #{id}: #{e.message}")
    nil
  end

  def watchlisted_by?(user)
    return false unless user
    watchlists.exists?(user_id: user.id)
  end


  def banner_url
    return unless banner.attached?
    blob = banner.blob
    return unless blob&.key.present? &&
                blob.filename.present? &&
                blob.content_type.present?
    banner.service.url(blob.key, eager: true)
  rescue ArgumentError => e
    Rails.logger.warn("Banner URL error for Movie #{id}: #{e.message}")
    nil
  end


  def self.ransackable_attributes(_auth_object = nil)
    %w[id title release_year rating genre_id director duration description main_lead streaming_platform premium
       created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[subscriptions users genre]
  end

  private

  def poster_attached?
    poster.attached?
  end

  def banner_attached?
    banner.attached?
  end

  def poster_content_type
    return unless poster.attached?

    return if poster.blob.content_type.in?(%w[image/jpeg image/png])

    errors.add(:poster, 'must be a JPEG or PNG')
  end

  def banner_content_type
    return unless banner.attached?

    return if banner.blob.content_type.in?(%w[image/jpeg image/png])

    errors.add(:banner, 'must be a JPEG or PNG')
  end
end
