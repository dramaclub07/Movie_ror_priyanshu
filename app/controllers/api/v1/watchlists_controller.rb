  module Api
    module V1
      class WatchlistsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_movie, only: [:create]

        def index
          watchlists = Watchlist.for_user(current_user).includes(movie: :genre)
          movies = watchlists.map { |watchlist| watchlist.movie }
          render json: movies, each_serializer: MovieSerializer, scope: current_user, status: :ok
        end

        def create
          return render json: { error: 'Movie not found' }, status: :not_found unless @movie

          watchlist = Watchlist.find_by(user: current_user, movie: @movie)
          if watchlist
            watchlist.destroy
            render json: { message: 'Movie removed from watchlist' }, status: :ok
          else
            watchlist = Watchlist.new(user: current_user, movie: @movie)
            begin
              if watchlist.save
                render json: watchlist, serializer: Api::V1::WatchlistSerializer, status: :created
              else
                render json: { error: watchlist.errors.full_messages.first }, status: :unprocessable_entity
              end
            rescue StandardError => e
              Rails.logger.error "Failed to create watchlist: #{e.message}"
              render json: { error: 'Failed to add movie to watchlist' }, status: :internal_server_error
            end
          end
        end

        private

        def set_movie
          @movie = Movie.find_by(id: params[:movie_id])
        rescue ActiveRecord::RecordNotFound
          @movie = nil
        end
      end
    end
  end