Rails.application.routes.draw do
  # Mount Rswag engines for API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      # Auth routes
      post 'auth/sign_up', to: 'auth#sign_up'
      post 'auth/sign_in', to: 'auth#sign_in'
      post 'auth/google', to: 'auth#google'
      post 'auth/refresh_token', to: 'auth#refresh_token'
      delete 'auth/sign_out', to: 'auth#sign_out'
      
      # Profile routes
      get 'profile', to: 'auth#profile'
      put 'update_profile', to: 'auth#update_profile'
      patch 'update_profile', to: 'auth#update_profile'

      # User routes (already defined profile & update routes, no need for repetition)
      resources :users, only: %i[show update]

      # Movie routes
      resources :movies do
        collection do
          get 'search'
          get 'recommended'
        end
        member do
          post 'rate'
          delete 'remove_rating'
        end
      end

      # Genre routes
      resources :genres

      # Subscription routes
      resources :subscriptions do
        collection do
          get 'active'
          get 'history'
        end
      end

      # Admin routes
      namespace :admin do
        resources :users, only: %i[index show update destroy]
        resources :movies
        resources :genres
        resources :subscriptions, only: %i[index show]
        get 'dashboard', to: 'dashboard#index'
      end
    end
  end

  # Catch-all route for React frontend - MUST be last
  get '*path', to: 'application#index', constraints: lambda { |request| 
    !request.xhr? && request.format.html? 
  }
end
