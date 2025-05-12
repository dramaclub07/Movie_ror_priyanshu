# Rails.application.routes.draw do
#   mount Rswag::Ui::Engine => '/api-docs'
#   mount Rswag::Api::Engine => '/api-docs'
#   root to: redirect('/api-docs')

#   devise_for :admin_users, ActiveAdmin::Devise.config
#   ActiveAdmin.routes(self)

#   namespace :api, defaults: { format: :json } do
#     namespace :v1 do
#       scope :auth do
#         post 'sign_up', to: 'auth#sign_up'
#         post 'sign_in', to: 'auth#sign_in'
#         post 'google', to: 'auth#google'
#         post 'refresh_token', to: 'auth#refresh_token'
#         delete 'sign_out', to: 'auth#sign_out'
#         get 'profile', to: 'auth#profile'
#         match 'update_profile', to: 'auth#update_profile', via: %i[put patch]
#       end

#       resources :users, only: %i[show update]

#       resources :subscriptions, only: %i[create index show destroy] do
#         get 'active', on: :collection
#         get 'success', on: :collection
#         get 'cancel', on: :collection
#       end

#       resources :movies do
#         collection { get :search, :recommended }
#         member do
#           post :rate
#           delete :remove_rating
#         end
#       end

#       resources :genres, only: %i[index show create update destroy]

#       scope :notifications do
#         post 'update_device_token', to: 'notifications#update_device_token'
#         post 'toggle_notifications', to: 'notifications#toggle_notifications'
#         post 'test', to: 'notifications#test_notification'
#       end
#     end
#   end

#   get '*path', to: 'application#index', constraints: ->(req) { !req.xhr? && req.format.html? }
# end
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
      post 'auth/google', to: 'auth#google'
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
      post 'watchlist/:movie_id', to: 'watchlists#toggle'

      # Notification routes
      post 'notifications/device-token', to: 'notifications#update_device_token'
      post 'notifications/toggle', to: 'notifications#toggle_notifications'
      post 'notifications/test', to: 'notifications#test_notification'
    end
  end

  get '*path', to: 'application#frontend', constraints: ->(req) { !req.xhr? && req.format.html? }
end