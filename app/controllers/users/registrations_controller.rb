# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
    before_action :validate_user_type, only: [:new, :create]
  
    private
  
    # There are only 3 possible roles for a user. If i tries to insert a different one
    # it will redirect to the default user normal registration page with the default user type
    def validate_user_type
        Rails.logger.debug("PIPPO")
        if params[:user_type].present?
            user_type = params[:user_type]
            if !UserRoles::ALL_ROLES.include?(user_type)
                Rails.logger.warn("Invalid user type: #{user_type}")
                redirect_to new_user_registration_path(user_type: UserRoles::USER_NORMAL)
                return 
            end
        end

        if params[:user] && !UserRoles::ALL_ROLES.include?(params[:user][:type])
            flash[:alert] = 'Invalid user type. Please try again.'
            # Redirect to the default user normal registration page
            redirect_to new_user_registration_path(user_type: UserRoles::USER_NORMAL)
        end
    end
  

  end
  