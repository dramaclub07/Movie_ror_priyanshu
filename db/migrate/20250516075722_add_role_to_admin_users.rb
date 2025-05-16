class AddRoleToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:admin_users, :role)
      add_column :admin_users, :role, :string, default: "admin"
    end
  end
end