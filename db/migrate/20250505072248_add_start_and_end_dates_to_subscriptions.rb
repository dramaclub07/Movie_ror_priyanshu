# frozen_string_literal: true

class AddStartAndEndDatesToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :end_date, :date
  end
end
