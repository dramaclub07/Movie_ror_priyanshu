# db/migrate/YYYYMMDDHHMMSS_create_watchlists.rb
class CreateWatchlists < ActiveRecord::Migration[7.1]
  def change
    create_table :watchlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.timestamps
    end
    add_index :watchlists, [:user_id, :movie_id], unique: true
  end
end