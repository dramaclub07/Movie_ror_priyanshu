class ChangeMovieIdNullableInSubscriptions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :subscriptions, :movie_id, true
  end
end
