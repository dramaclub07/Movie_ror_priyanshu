# app/controllers/api/v1/movies_controller.rb
module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!, only: %i[index show]
      before_action :authorize_supervisor!, only: %i[create update destroy]
      before_action :set_movie, only: %i[show update destroy]
      before_action :restrict_premium_content, only: %i[index show]

      def index
        movies = Movie.includes(:genre)
        movies = movies.where('title ILIKE ?', "%#{params[:search]}%") if params[:search].present?
        movies = movies.where(genre_id: params[:genre_id]) if params[:genre_id].present?
        movies = movies.where(premium: false) unless current_user&.subscriptions&.active&.where(plan_type: 'premium')&.exists?
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
        if @movie.premium && !current_user&.subscriptions&.active&.where(plan_type: 'premium')&.exists?
          render json: { error: 'Premium subscription required' }, status: :forbidden
        else
          render json: @movie, serializer: MovieSerializer, status: :ok
        end
      end

      def create
        @movie = Movie.new(movie_params.except(:poster, :banner))
        if params[:movie][:poster].present? && params[:movie][:poster].is_a?(ActionDispatch::Http::UploadedFile)
          @movie.poster.attach(params[:movie][:poster])
        end
        if params[:movie][:banner].present? && params[:movie][:banner].is_a?(ActionDispatch::Http::UploadedFile)
          @movie.banner.attach(params[:movie][:banner])
        end
        if @movie.save
          notify_new_movie(@movie)
          render json: {
            message: 'Movie created successfully',
            movie: ActiveModelSerializers::SerializableResource.new(@movie, serializer: MovieSerializer)
          }, status: :created
        else
          Rails.logger.error "Movie save failed: #{@movie.errors.full_messages}"
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @movie.update(movie_params.except(:poster, :banner))
          if params[:movie][:poster].present? && params[:movie][:poster].is_a?(ActionDispatch::Http::UploadedFile)
            @movie.poster.purge
            @movie.poster.attach(params[:movie][:poster])
          end
          if params[:movie][:banner].present? && params[:movie][:banner].is_a?(ActionDispatch::Http::UploadedFile)
            @movie.banner.purge
            @movie.banner.attach(params[:movie][:banner])
          end
          render json: @movie, serializer: MovieSerializer, status: :ok
        else
          Rails.logger.error "Movie update failed: #{@movie.errors.full_messages}"
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @movie.destroy
          render json: { message: 'Movie deleted successfully' }, status: :ok
        else
          render json: { error: 'Failed to delete movie' }, status: :unprocessable_entity
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
          :title, :release_year, :rating, :genre_id, :director, :duration,
          :description, :main_lead, :streaming_platform, :premium, :poster, :banner
        )
      end

      def authorize_supervisor!
        is_supervisor = current_user&.supervisor?
        Rails.logger.debug "User #{current_user&.id} authorization: supervisor?=#{is_supervisor}, role=#{current_user&.role}"
        return if is_supervisor

        Rails.logger.warn "Authorization failed for user #{current_user&.id}: role=#{current_user&.role}"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def restrict_premium_content
        # Handled in index and show actions
      end

      def notify_new_movie(movie)
        users = User.where(notifications_enabled: true).where.not(device_token: [nil, ''])
        return if users.empty?

        device_tokens = users.pluck(:device_token)
        begin
          fcm_service = FcmService.new
          result = fcm_service.send_notification(
            device_tokens,
            'New Movie Added!',
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