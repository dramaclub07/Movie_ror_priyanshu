ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :role

  index do
    selectable_column
    id_column
    column :email
    column :role do |user|
      status_tag user.role, class: user.role == 'admin' ? 'ok' : 'warning'
    end
    column :current_sign_in_at
    column :created_at
    actions
  end

  filter :email
  filter :role, as: :select, collection: %w[admin editor viewer]
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: %w[admin editor viewer]
    end
    f.actions
  end
end
