class Watchlist < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  # Add uniqueness validation
  validates :movie_id, uniqueness: { 
    scope: :user_id, 
    message: 'has already been added to watchlist' 
  }

  # Add scope for user's watchlist
  scope :for_user, ->(user) { where(user: user) }

  # Add callback for notifications
  after_create :send_notification

  private

  def send_notification
    WatchlistNotificationJob.perform_later(self)
  end
end