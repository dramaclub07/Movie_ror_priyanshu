# db/migrate/YYYYMMDDHHMMSS_remove_genre_string_from_movies.rb
class RemoveGenreStringFromMovies < ActiveRecord::Migration[7.1]
  def change
    remove_column :movies, :genre, :string if column_exists?(:movies, :genre)
  end
end
