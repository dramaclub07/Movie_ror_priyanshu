class AddOmniAuthToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_users, :provider, :string
    add_column :admin_users, :uid, :string
    add_index :admin_users, %i[provider uid], unique: true
  end
end
