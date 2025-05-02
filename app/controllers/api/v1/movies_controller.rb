# app/controllers/api/v1/movies_controller.rb
module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :authorize_admin_or_supervisor!, only: [:create, :update, :destroy]
      before_action :set_movie, only: [:show, :update, :destroy]

      # GET /api/v1/movies
      def index
        movies = Movie.includes(:genre)
        movies = movies.where('title ILIKE ?', "%#{params[:search]}%") if params[:search].present?
        movies = movies.where(genre_id: params[:genre_id]) if params[:genre_id].present?
        movies = movies.page(params[:page]).per(10)

        render json: {
          movies: ActiveModelSerializers::SerializableResource.new(movies, each_serializer: MovieSerializer),
          meta: {
            current_page: movies.current_page,
            total_pages: movies.total_pages,
            total_count: movies.total_count
          }
        }, status: :ok
      end

      # GET /api/v1/movies/:id
      def show
        render json: @movie, serializer: MovieSerializer, status: :ok
      end

      # POST /api/v1/movies
      def create
        @movie = Movie.new(movie_params.except(:poster, :banner))
        @movie.poster.attach(params[:movie][:poster]) if params[:movie][:poster].present?
        @movie.banner.attach(params[:movie][:banner]) if params[:movie][:banner].present?

        if @movie.save
          render json: {
            message: "Movie created successfully",
            movie: ActiveModelSerializers::SerializableResource.new(@movie, serializer: MovieSerializer)
          }, status: :created
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/movies/:id
      def update
        if @movie.update(movie_params.except(:poster, :banner))
          if params[:movie][:poster].present?
            @movie.poster.purge
            @movie.poster.attach(params[:movie][:poster])
          end
          if params[:movie][:banner].present?
            @movie.banner.purge
            @movie.banner.attach(params[:movie][:banner])
          end
          render json: @movie, serializer: MovieSerializer, status: :ok
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/movies/:id
      def destroy
        if @movie.subscriptions.exists?
          render json: { error: 'Cannot delete movie with active subscriptions' }, status: :unprocessable_entity
        elsif @movie.destroy
          render json: { message: "Movie deleted successfully" }, status: :ok
        else
          render json: { error: "Failed to delete movie" }, status: :unprocessable_entity
        end
      end

      private

      def set_movie
        @movie = Movie.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Movie not found' }, status: :not_found
      end

      def movie_params
        params.require(:movie).permit(
          :title,
          :release_year,
          :rating,
          :genre_id,
          :poster,
          :banner,
          :director,
          :duration,
          :description,
          :main_lead,
          :streaming_platform,
          :premium
        )
      end

      def authorize_admin_or_supervisor!
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end