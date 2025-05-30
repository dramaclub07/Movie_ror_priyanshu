module Api
  module V1
    class GenresController < ApplicationController
      before_action :set_genre, only: %i[show update destroy]
      before_action :authenticate_user!, except: %i[index show]
      before_action :authorize_supervisor!, only: %i[create update destroy]

      def index
        @genres = Genre.all
        render json: @genres
      end

      def show
        render json: @genre.as_json(include: :movies)
      end

      def create
        @genre = Genre.new(genre_params)

        if @genre.save
          render json: @genre, status: :created
        else
          render json: { errors: @genre.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @genre.update(genre_params)
          render json: @genre
        else
          render json: { errors: @genre.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @genre.movies.exists?
          render json: { error: 'Cannot delete genre with associated movies' }, status: :unprocessable_entity
        else
          @genre.destroy
          head :no_content
        end
      end

      private

      def set_genre
        @genre = Genre.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Genre not found' }, status: :not_found
      end

      def genre_params
        params.require(:genre).permit(:name)
      end

      def authorize_supervisor!
        return if current_user&.supervisor?

        render json: { error: 'Unauthorized access' }, status: :forbidden
      end
    end
  end
end
