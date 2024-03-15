# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
    before_action :validate_user_type, only: [:create]
  
    private
  
    def validate_user_type
        Rails.logger.info("CHIAMO User type: #{params[:user][:type]}")
      if params[:user] && !valid_user_types.include?(params[:user][:type])
        flash[:alert] = 'Invalid user type. Please try again.'
        # Redirect to the default userNormal registration page
        redirect_to new_user_registration_path(user_type: 'UserNormal')
      end
    end
  
    def valid_user_types
      %w[UserNormal UserOrganizer CompanyOrganizer]
    end
  end
  