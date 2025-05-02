# app/serializers/movie_serializer.rb
class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :release_year, :rating, :director, :duration,
             :description, :main_lead, :streaming_platform, :premium,
             :created_at, :updated_at

  belongs_to :genre, serializer: GenreSerializer
  attribute :poster_url
  attribute :banner_url

  def poster_url
    Rails.application.routes.url_helpers.url_for(object.poster) if object.poster.attached?
  end

  def banner_url
    Rails.application.routes.url_helpers.url_for(object.banner) if object.banner.attached?
  end
end