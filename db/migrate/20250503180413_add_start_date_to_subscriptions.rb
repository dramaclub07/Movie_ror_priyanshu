class AddStartDateToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :start_date, :datetime
  end
end
