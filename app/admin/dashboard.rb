# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Recent Movies' do
          ul do
            Movie.order(created_at: :desc).limit(5).map do |movie|
              li link_to(movie.title, admin_movie_path(movie))
            end
          end
        end
      end

      column do
        panel 'Top Genres by Movie Count' do
          ul do
            Genre
              .left_joins(:movies)
              .group(:id, :name) # Fix: Add all selected fields to GROUP BY
              .order('COUNT(movies.id) DESC')
              .limit(5)
              .pluck(:name, Arel.sql('COUNT(movies.id)'))
              .map do |name, count|
                li "#{name} - #{count} movies"
              end
          end
        end
      end
    end
  end
end
