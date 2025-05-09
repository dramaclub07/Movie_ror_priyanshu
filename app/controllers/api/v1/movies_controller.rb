module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :authorize_admin_or_supervisor!, only: [:create, :update, :destroy]
      before_action :set_movie, only: [:show, :update, :destroy]

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

      def show
        render json: @movie, serializer: MovieSerializer, status: :ok
      end

      def create
        @movie = Movie.new(movie_params.except(:poster, :banner))
        
        Rails.logger.info "Poster param: #{params[:movie][:poster].inspect}"
        Rails.logger.info "Banner param: #{params[:movie][:banner].inspect}"

        if params[:movie][:poster].present? && params[:movie][:poster].is_a?(ActionDispatch::Http::UploadedFile)
          @movie.poster.attach(params[:movie][:poster])
          Rails.logger.info "Poster attached: #{@movie.poster.attached?}"
        end

        if params[:movie][:banner].present? && params[:movie][:banner].is_a?(ActionDispatch::Http::UploadedFile)
          @movie.banner.attach(params[:movie][:banner])
          Rails.logger.info "Banner attached: #{@movie.banner.attached?}"
        end

        if @movie.save
          notify_new_movie(@movie) # Call notification method
          render json: {
            message: "Movie created successfully",
            movie: ActiveModelSerializers::SerializableResource.new(@movie, serializer: MovieSerializer)
          }, status: :created
        else
          Rails.logger.error "Movie save failed: #{@movie.errors.full_messages}"
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/movies/:id
      def update
        if @movie.update(movie_params.except(:poster, :banner))
          # Log incoming file params for debugging
          Rails.logger.info "Poster param: #{params[:movie][:poster].inspect}"
          Rails.logger.info "Banner param: #{params[:movie][:banner].inspect}"

          if params[:movie][:poster].present? && params[:movie][:poster].is_a?(ActionDispatch::Http::UploadedFile)
            @movie.poster.purge
            @movie.poster.attach(params[:movie][:poster])
            Rails.logger.info "Poster updated: #{@movie.poster.attached?}"
          end

          if params[:movie][:banner].present? && params[:movie][:banner].is_a?(ActionDispatch::Http::UploadedFile)
            @movie.banner.purge
            @movie.banner.attach(params[:movie][:banner])
            Rails.logger.info "Banner updated: #{@movie.banner.attached?}"
          end

          render json: @movie, serializer: MovieSerializer, status: :ok
        else
          Rails.logger.error "Movie update failed: #{@movie.errors.full_messages}"
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
          :director,
          :duration,
          :description,
          :main_lead,
          :streaming_platform,
          :premium,
          :poster,
          :banner
        )
      end

      def authorize_admin_or_supervisor!
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: "Unauthorized" }, status: :Kalunauthorized
        end
      end

      def notify_new_movie(movie)
        # Find users eligible for notifications
        users = User.where(notifications_enabled: true).where.not(device_token: [nil, ""])
        return if users.empty?

        device_tokens = users.pluck(:device_token)
        begin
          fcm_service = FcmService.new
          result = fcm_service.send_notification(
            device_tokens,
            "New Movie Added!",
            "#{movie.title} has been added to the Movie Explorer collection.",
            { movie_id: movie.id.to_s }
          )
          Rails.logger.info "FCM notification result: #{result[:message]}"
        rescue StandardError => e
          Rails.logger.error "Failed to send FCM notification for movie #{movie.id}: #{e.message}"
        end
      end
    end
  end
end