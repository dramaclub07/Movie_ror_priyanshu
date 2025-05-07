class AddDeviceTokenAndNotificationsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :device_token, :string
    add_column :users, :notifications_enabled, :boolean, default: true
  end
end
