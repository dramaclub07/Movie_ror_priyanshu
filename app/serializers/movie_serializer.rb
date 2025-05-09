class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :release_year, :rating, :director, :duration,
             :description, :main_lead, :streaming_platform, :premium,
             :poster_url, :banner_url, :created_at, :updated_at

  belongs_to :genre, serializer: GenreSerializer
end
