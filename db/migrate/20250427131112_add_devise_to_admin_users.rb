# frozen_string_literal: true

class AddDeviseToAdminUsers < ActiveRecord::Migration[7.1]
  def self.up
    # Only add columns if they don't exist
    unless column_exists? :admin_users, :email
      change_table :admin_users do |t|
        t.string :email, null: false, default: ''
      end
    end

    # Clean up any existing records with empty emails
    execute "DELETE FROM admin_users WHERE email IS NULL OR email = '';"

    unless column_exists? :admin_users, :encrypted_password
      change_table :admin_users do |t|
        t.string :encrypted_password, null: false, default: ''
      end
    end

    unless column_exists? :admin_users, :reset_password_token
      change_table :admin_users do |t|
        t.string :reset_password_token
        t.datetime :reset_password_sent_at
      end
    end

    unless column_exists? :admin_users, :remember_created_at
      change_table :admin_users do |t|
        t.datetime :remember_created_at
      end
    end

    # Add indexes only if they don't exist
    add_index :admin_users, :email, unique: true unless index_exists? :admin_users, :email

    add_index :admin_users, :reset_password_token, unique: true unless index_exists? :admin_users, :reset_password_token

    # Uncomment and add these if you need confirmable or lockable
    # unless column_exists? :admin_users, :confirmation_token
    #   change_table :admin_users do |t|
    #     t.string :confirmation_token
    #     t.datetime :confirmed_at
    #     t.datetime :confirmation_sent_at
    #     t.string :unconfirmed_email
    #   end
    #   add_index :admin_users, :confirmation_token, unique: true
    # end

    # unless column_exists? :admin_users, :failed_attempts
    #   change_table :admin_users do |t|
    #     t.integer :failed_attempts, default: 0, null: false
    #     t.string :unlock_token
    #     t.datetime :locked_at
    #   end
    #   add_index :admin_users, :unlock_token, unique: true
    # end

    # Add timestamps if not present
    return if column_exists? :admin_users, :created_at

    change_table :admin_users do |t|
      t.timestamps null: false
    end
  end

  def self.down
    # Remove columns if they exist
    remove_column :admin_users, :email if column_exists? :admin_users, :email
    remove_column :admin_users, :encrypted_password if column_exists? :admin_users, :encrypted_password
    remove_column :admin_users, :reset_password_token if column_exists? :admin_users, :reset_password_token
    remove_column :admin_users, :reset_password_sent_at if column_exists? :admin_users, :reset_password_sent_at
    remove_column :admin_users, :remember_created_at if column_exists? :admin_users, :remember_created_at
    # Remove indexes if they exist
    remove_index :admin_users, :email if index_exists? :admin_users, :email
    remove_index :admin_users, :reset_password_token if index_exists? :admin_users, :reset_password_token
    # Remove timestamps if added
    return unless column_exists? :admin_users, :created_at

    remove_column :admin_users, :created_at
    remove_column :admin_users, :updated_at
  end
end
