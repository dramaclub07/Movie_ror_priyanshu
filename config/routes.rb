Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      # Auth
      post 'auth/sign_up', to: 'auth#sign_up'
      post 'auth/sign_in', to: 'auth#sign_in'
      post 'auth/google', to: 'auth#google'
      post 'auth/refresh_token', to: 'auth#refresh_token'
      delete 'auth/sign_out', to: 'auth#sign_out'

      get 'profile', to: 'auth#profile'
      put 'update_profile', to: 'auth#update_profile'
      patch 'update_profile', to: 'auth#update_profile'

      # Users
      resources :users, only: %i[show update]
      #subscription

      post   'subscriptions',           to: 'subscriptions#create'
      get    'subscriptions',           to: 'subscriptions#index'
      get    'subscriptions/:id',       to: 'subscriptions#show'
      get    'subscriptions/active',    to: 'subscriptions#active'
      get    'subscriptions/success',   to: 'subscriptions#success'
      get    'subscriptions/cancel',    to: 'subscriptions#cancel'
      # Movies
      
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

      # Genres
      resources :genres

    

      # Admin
      namespace :admin do
        resources :users, only: %i[index show update destroy]
        resources :movies
        resources :genres
        resources :subscriptions, only: %i[index show]
        get 'dashboard', to: 'dashboard#index'
      end
    end
  end

  # Frontend catch-all
  get '*path', to: 'application#index', constraints: lambda { |request| 
    !request.xhr? && request.format.html? 
  }
end
