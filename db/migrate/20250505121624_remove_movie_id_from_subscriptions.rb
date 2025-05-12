# frozen_string_literal: true

class RemoveMovieIdFromSubscriptions < ActiveRecord::Migration[7.1]
  def change
    remove_column :subscriptions, :movie_id, :bigint
  end
end
