ActiveAdmin.register Subscription do
  permit_params :user_id, :plan_type, :status

  index do
    selectable_column
    id_column
    column :user
    column :plan_type
    column :status
    column :created_at
    actions
  end

  filter :user
  filter :plan_type
  filter :status
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :plan_type, as: :select, collection: %w[basic premium]
      f.input :status, as: :select, collection: %w[active inactive]
    end
    f.actions
  end
end
