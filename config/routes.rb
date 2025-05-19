Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  root to: redirect('/api-docs')

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Authentication routes
      post 'register', to: 'auth#register'
      post 'login', to: 'auth#login'
      post 'google', to: 'auth#google'
      post 'refresh-token', to: 'auth#refresh_token'
      delete 'logout', to: 'auth#logout'
      get 'profile', to: 'auth#profile'
      put 'profile', to: 'auth#update_profile'

      # Genre routes
      resources :genres, only: [:index, :show, :create, :update, :destroy]

      # Movie routes
      resources :movies, only: [:index, :show, :create, :update, :destroy]

      # Subscription routes
      resources :subscriptions, only: [:index, :show, :create] do
        get 'success', on: :collection
        get 'cancel', on: :collection
        get 'active', on: :collection
      end

      # Watchlist routes
      resources :watchlist, only: [:index]
      post 'watchlist/:movie_id', to: 'watchlists#create'
      post 'watchlists/toggle/:movie_id', to: 'watchlists#create', as: :watchlist_toggle

      # Notification routes
      post 'notifications/device-token', to: 'notifications#update_device_token'
      post 'notifications/toggle', to: 'notifications#toggle_notifications'
      post 'notifications/test', to: 'notifications#test_notification'
    end
  end

  get '*path', to: 'application#frontend', constraints: ->(req) { !req.xhr? && req.format.html? }
end