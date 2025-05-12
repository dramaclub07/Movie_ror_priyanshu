# frozen_string_literal: true

class AddRefreshTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :refresh_token, :string, null: true
    add_index :users, :refresh_token, unique: true
  end
end
