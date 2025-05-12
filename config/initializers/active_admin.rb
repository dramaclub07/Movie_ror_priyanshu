# ActiveAdmin.setup do |config|
#   config.site_title = "Movie Explorer App"
#   config.register_stylesheet 'active_admin.css'
#   config.register_javascript 'active_admin.js'

#   config.authentication_method = :authenticate_admin_user!
#   config.current_user_method = :current_admin_user
#   config.logout_link_path = :destroy_admin_user_session_path
#   config.logout_link_method = :delete
#   config.root_to = 'dashboard#index'

#   config.batch_actions = true
#   config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
#   config.localize_format = :long
# end
ActiveAdmin.setup do |config|
  config.namespace :admin do |admin|
    admin.authentication_method = :authenticate_admin_user!
    admin.current_user_method = :current_admin_user
    admin.logout_link_path = :destroy_admin_user_session_path
    admin.root_to = 'dashboard#index'
  end

  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path

  config.site_title = 'Movie Explorer App Admin'
  config.comments = false
  config.batch_actions = true
end
