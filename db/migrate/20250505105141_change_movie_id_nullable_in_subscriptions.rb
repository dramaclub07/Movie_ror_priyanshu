# frozen_string_literal: true

class ChangeMovieIdNullableInSubscriptions < ActiveRecord::Migration[7.1]
  def change
    change_column_null :subscriptions, :movie_id, true
  end
end
