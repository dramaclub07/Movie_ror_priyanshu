# app/serializers/api/v1/watchlist_serializer.rb
module Api
  module V1
    class WatchlistSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :movie_id, :created_at, :updated_at
    end
  end
end