# frozen_string_literal: true

class ChangeMobileNumberAndPasswordDigestToNullableInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :phone_number, true
    change_column_null :users, :password_digest, true
  end
end
