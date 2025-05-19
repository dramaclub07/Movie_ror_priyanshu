class WatchlistNotificationJob < ApplicationJob
  queue_as :default
  def perform(watchlist)
    return unless watchlist.user.notifications_enabled && watchlist.user.device_token.present?
    begin
      fcm_service = FcmService.new
      result = fcm_service.send_notification(
        [watchlist.user.device_token],
        'Movie Added to Watchlist',
        "You added #{watchlist.movie.title} to your watchlist!",
        { movie_id: watchlist.movie_id.to_s }
      )
      Rails.logger.info "FCM notification for watchlist #{watchlist.id}: #{result[:message]}"
    rescue StandardError => e
      Rails.logger.error "Failed to send FCM notification for watchlist #{watchlist.id}: #{e.message}"
    end
  end
end