# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def new
    build_resource({})
    resource.type = params[:user_type] if params[:user_type].in?(['NormalUser', 'UserOrganizer', 'CompanyOrganizer'])

    #respond_with resource
    case params[:user_type]
    when 'NormalUser'
      render 'devise/registrations/new_user' and return # Make sure this is the correct path
    when 'UserOrganizer' 
      render 'devise/registrations/new_organizer' and return # Make sure this is the correct path
    else
      render 'devise/registrations/new_user' and return #defult view
    end
  end

  def edit

    Rails.logger.debug "Overridden edit action is being called"
    #never use 'super' otherwise it uses the default devise views
    case resource.type
    when 'NormalUser'
      render 'devise/registrations/edit_user' and return
    when 'UserOrganizer'
      render 'devise/registrations/edit_organizer' and return
    when 'CompanyOrganizer'
      render 'devise/registrations/edit_organizer' and return
    else
      render 'devise/registrations/edit_user' # Default view or handle as needed
    end
    
  end
  

  # POST /resource
  def create
    super
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname, :date_of_birth, :phone, :address, :cap, :city, :province, :state, :type])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :surname, :date_of_birth, :address, :cap, :province, :city, :state, :phone])

  end
end
