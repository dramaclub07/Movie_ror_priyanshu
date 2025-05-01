ActiveAdmin.register Movie do
  permit_params :title, :release_year, :rating, :genre_id, :poster

  index do
    selectable_column
    id_column
    column :title
    column :release_year
    column :rating
    column :genre
    column :poster do |movie|
      if movie.poster.attached?
        image_tag url_for(movie.poster), width: 100
      end
    end
    actions
  end

  show do
    attributes_table do
      row :title
      row :release_year
      row :rating
      row :genre
      row :poster do |movie|
        if movie.poster.attached?
          image_tag url_for(movie.poster), width: 200
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :release_year
      f.input :rating
      f.input :genre
      f.input :poster, as: :file
    end
    f.actions
  end
end 