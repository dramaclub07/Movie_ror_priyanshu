ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :email, :phone_number, :password_digest, :role, :google_id, :refresh_token, :github_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :email, :phone_number, :password_digest, :role, :google_id, :refresh_token, :github_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
