class AddFieldsToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :title, :string unless column_exists?(:movies, :title)
    add_column :movies, :genre, :string unless column_exists?(:movies, :genre)
    add_column :movies, :release_year, :integer unless column_exists?(:movies, :release_year)
    add_column :movies, :rating, :float unless column_exists?(:movies, :rating)
    add_column :movies, :director, :string unless column_exists?(:movies, :director)
    add_column :movies, :duration, :integer unless column_exists?(:movies, :duration)
    add_column :movies, :description, :text unless column_exists?(:movies, :description)
    add_column :movies, :main_lead, :string unless column_exists?(:movies, :main_lead)
    add_column :movies, :streaming_platform, :string unless column_exists?(:movies, :streaming_platform)
    add_column :movies, :premium, :boolean, default: true unless column_exists?(:movies, :premium)
  end
end
