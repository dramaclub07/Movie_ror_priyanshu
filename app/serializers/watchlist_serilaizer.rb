# app/serializers/movie_serializer.rb
class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :release_year, :rating, :director, :duration, :description,
             :main_lead, :streaming_platform, :premium, :poster_url, :banner_url,
             :created_at, :updated_at, :watchlisted
  belongs_to :genre

  def watchlisted
    scope && object.watchlists.exists?(user_id: scope.id)
  end
end