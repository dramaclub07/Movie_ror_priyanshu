ActiveAdmin.register Movie do
  permit_params :title, :description, :video, :poster, :banner, :trailer, :runtime,
                :imdb_rating, :language, :certificate, :release_year,
                :premium, :genre_id

  index do
    selectable_column
    id_column
    column :title
    column :language
    column :imdb_rating
    column :certificate
    column :release_year

    column :premium do |movie|
      status_tag movie.premium? ? "Yes" : "No", class: movie.premium? ? "ok" : "error"
    end

    column :genre

    column "Poster" do |movie|
      if movie.poster.attached?
        image_tag movie.poster.service_url, height: "50"
      else
        status_tag "No Image", :warning
      end
    end

    actions
  end
end
