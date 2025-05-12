# app/serializers/genre_serializer.rb
class GenreSerializer < ActiveModel::Serializer
  attributes :id, :name
end
