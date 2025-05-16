class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: '' unless column_exists?(:users, :encrypted_password)

      ## Recoverable
      t.string   :reset_password_token unless column_exists?(:users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:users, :reset_password_sent_at)

      ## Rememberable
      t.datetime :remember_created_at unless column_exists?(:users, :remember_created_at)

      ## Omniauthable
      t.string :provider unless column_exists?(:users, :provider)
      t.string :uid unless column_exists?(:users, :uid)
    end

    ## Add indexes only if they don't exist
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    # Skipping email index since it already exists and caused the error
  end
end
