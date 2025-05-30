class AddDeviseToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:admin_users)
      create_table :admin_users do |t|
        ## Database authenticatable
        t.string :email,              null: false, default: ''
        t.string :encrypted_password, null: false, default: ''

        ## Recoverable
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at

        ## Rememberable
        t.datetime :remember_created_at

        ## Trackable
        t.integer  :sign_in_count, default: 0, null: false
        t.datetime :current_sign_in_at
        t.datetime :last_sign_in_at
        t.string   :current_sign_in_ip
        t.string   :last_sign_in_ip

        ## Add role column for admin/supervisor
        t.string :role, default: 'admin'

        t.timestamps null: false
      end

      add_index :admin_users, :email, unique: true
      add_index :admin_users, :reset_password_token, unique: true
    end
  end
end
