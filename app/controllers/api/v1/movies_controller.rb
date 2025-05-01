module Api
  module V1
    class MoviesController < ApplicationController
      before_action :authenticate_user!, except: %i[index show]
      before_action :set_movie, only: %i[show update destroy]
      before_action :authorize_admin!, only: %i[create update destroy]

      # GET /api/v1/movies
      def index
        @movies = Movie.includes(:genre)

        # Filter by genre
        @movies = @movies.where(genre_id: params[:genre_id]) if params[:genre_id].present?

        # Filter by release year
        @movies = @movies.where(release_year: params[:year]) if params[:year].present?

        # Filter by rating
        @movies = @movies.where(rating: params[:rating]) if params[:rating].present?

        # Search by title
        @movies = @movies.where('title ILIKE ?', "%#{params[:search]}%") if params[:search].present?

        # Sort by release year or rating
        case params[:sort]
        when 'year_asc'
          @movies = @movies.order(release_year: :asc)
        when 'year_desc'
          @movies = @movies.order(release_year: :desc)
        when 'rating_asc'
          @movies = @movies.order(rating: :asc)
        when 'rating_desc'
          @movies = @movies.order(rating: :desc)
        end

        # Paginate results
        @movies = @movies.page(params[:page] || 1).per(params[:per_page] || 10)

        render json: {
          movies: @movies.as_json(include: :genre, methods: [:poster_url]),
          total_pages: @movies.total_pages,
          current_page: @movies.current_page,
          total_count: @movies.total_count
        }
      end

      # GET /api/v1/movies/:id
      def show
        render json: @movie.as_json(
          include: :genre,
          methods: [:poster_url]
        )
      end

      # POST /api/v1/movies
      def create
        @movie = Movie.new(movie_params)

        if @movie.save
          render json: @movie.as_json(include: :genre, methods: [:poster_url]), status: :created
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/movies/:id
      def update
        if @movie.update(movie_params)
          render json: @movie.as_json(include: :genre, methods: [:poster_url])
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/movies/:id
      def destroy
        if @movie.subscriptions.exists?
          render json: { error: 'Cannot delete movie with active subscriptions' }, status: :unprocessable_entity
        else
          @movie.destroy
          head :no_content
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
          :director,
          :duration,
          :description,
          :main_lead,
          :streaming_platform,
          :premium
        )
      end

      def authorize_admin!
        return if current_user&.admin?

        render json: { error: 'Unauthorized access' }, status: :forbidden
      end
    end
  end
end
