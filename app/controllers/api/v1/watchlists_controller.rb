# app/controllers/api/v1/watchlist_controller.rb
module Api
  module V1
    class WatchlistController < ApplicationController
      before_action :authenticate_user!
      before_action :set_movie, only: [:create]

      def index
        movies = current_user.watchlist_movies.includes(:genre)
        render json: movies, each_serializer: MovieSerializer, status: :ok
      end

      def create
        watchlist = current_user.watchlists.find_or_initialize_by(movie_id: params[:movie_id])
        if watchlist.persisted?
          watchlist.destroy
          render json: { message: "Movie removed from watchlist" }, status: :ok
        else
          watchlist.save!
          render json: watchlist, status: :created
        end
      end

      private

      def set_movie
        @movie = Movie.find(params[:movie_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Movie not found" }, status: :not_found
      end
    end
  end
end