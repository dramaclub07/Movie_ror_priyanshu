class UpdateUserRoles < ActiveRecord::Migration[7.1]
  def up
    User.where(role: '0').update_all(role: 'user')
    User.where(role: '1').update_all(role: 'supervisor')
    User.where(role: '2').update_all(role: 'admin')
  end

  def down
    # Optionally, revert changes
    User.where(role: 'user').update_all(role: '0')
    User.where(role: 'supervisor').update_all(role: '1')
    User.where(role: 'admin').update_all(role: '2')
  end
end
