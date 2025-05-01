class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'user' # Default role as 'user'

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :phone_number, unique: true
  end
end