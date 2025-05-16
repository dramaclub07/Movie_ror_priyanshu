class AddColumnsToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    # Add missing columns first
    unless column_exists?(:subscriptions, :stripe_customer_id)
      add_column :subscriptions, :stripe_customer_id, :string
    end

    unless column_exists?(:subscriptions, :stripe_subscription_id)
      add_column :subscriptions, :stripe_subscription_id, :string
    end

    unless column_exists?(:subscriptions, :status)
      add_column :subscriptions, :status, :string
    end

    # Then safely add indexes
    unless index_exists?(:subscriptions, :stripe_customer_id)
      add_index :subscriptions, :stripe_customer_id
    end

    unless index_exists?(:subscriptions, :stripe_subscription_id)
      add_index :subscriptions, :stripe_subscription_id
    end

    unless index_exists?(:subscriptions, :status)
      add_index :subscriptions, :status
    end
  end
end
