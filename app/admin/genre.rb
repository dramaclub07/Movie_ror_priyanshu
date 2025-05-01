ActiveAdmin.register Genre do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column :movies_count do |genre|
      genre.movies.count
    end
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end
end 