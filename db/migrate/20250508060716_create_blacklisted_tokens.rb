# frozen_string_literal: true

class CreateBlacklistedTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :token, null: false
      t.integer :user_id
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :blacklisted_tokens, :token, unique: true
  end
end
