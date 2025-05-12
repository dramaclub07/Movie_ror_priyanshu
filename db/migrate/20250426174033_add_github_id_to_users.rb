class AddGithubIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :github_id, :string, null: true
    add_index :users, :github_id, unique: true
  end
end
