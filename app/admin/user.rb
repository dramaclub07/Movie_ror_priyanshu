ActiveAdmin.register User do
  permit_params :email, :phone_number, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :phone_number
    column :created_at
    actions
  end

  filter :email
  filter :phone_number
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :phone_number
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end 