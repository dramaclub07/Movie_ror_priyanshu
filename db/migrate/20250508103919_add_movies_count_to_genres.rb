# frozen_string_literal: true

class AddMoviesCountToGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :genres, :movies_count, :integer, default: 0, null: false
  end
end
