# app/serializers/movie_serializer.rb
class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :release_year, :rating, :director, :duration,
             :description, :main_lead, :streaming_platform, :premium,
             :poster_url, :banner_url, :created_at, :updated_at

  belongs_to :genre, serializer: GenreSerializer

  def poster_url
    if object.poster.attached?
      begin
        Rails.application.routes.url_helpers.url_for(object.poster.variant(resize_to_limit: [300, 300]).processed)
      rescue => e
        logger.error "Failed to generate poster URL for movie #{object.id}: #{e.message}"
        nil
      end
    end
  end

  def banner_url
    if object.banner.attached?
      begin
        Rails.application.routes.url_helpers.url_for(object.banner.variant(resize_to_limit: [600, 200]).processed)
      rescue => e
        logger.error "Failed to generate banner URL for movie #{object.id}: #{e.message}"
        nil
      end
    end
  end
end