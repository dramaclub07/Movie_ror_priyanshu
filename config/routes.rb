Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  root to: redirect('/api-docs')

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      scope :auth do
        post 'sign_up', to: 'auth#sign_up'
        post 'sign_in', to: 'auth#sign_in'
        post 'google', to: 'auth#google'
        post 'refresh_token', to: 'auth#refresh_token'
        delete 'sign_out', to: 'auth#sign_out'
        get 'profile', to: 'auth#profile'
        match 'update_profile', to: 'auth#update_profile', via: %i[put patch]
      end

      resources :users, only: %i[show update]

      resources :subscriptions, only: %i[create index show destroy] do
        get 'active', on: :collection
        get 'success', on: :collection
        get 'cancel', on: :collection
      end

      resources :movies do
        collection { get :search, :recommended }
        member { post :rate; delete :remove_rating }
      end

      resources :genres, only: %i[index show create update destroy]

      scope :notifications do
        post 'update_device_token', to: 'notifications#update_device_token'
        post 'toggle_notifications', to: 'notifications#toggle_notifications'
        post 'test', to: 'notifications#test_notification'
      end
    end
  end

  get '*path', to: 'application#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end