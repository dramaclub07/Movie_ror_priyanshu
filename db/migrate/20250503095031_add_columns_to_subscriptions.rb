class AddColumnsToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_index :subscriptions, :stripe_customer_id, unless: index_exists?(:subscriptions, :stripe_customer_id)
    add_index :subscriptions, :stripe_subscription_id, unless: index_exists?(:subscriptions, :stripe_subscription_id)
    add_index :subscriptions, :status, unless: index_exists?(:subscriptions, :status)
  end
end
