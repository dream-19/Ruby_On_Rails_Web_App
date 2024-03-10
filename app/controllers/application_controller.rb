class ApplicationController < ActionController::Base
    #configurations for devise (must be done in ApplicationController otherwise they won't have an effect)

    before_action :configure_permitted_parameters, if: :devise_controller?

    protected
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname, :date_of_birth, :address, :cap, :province, :city, :state, :phone])
      # If you also want to allow users to edit these fields later, you can add:
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :surname, :date_of_birth, :address, :cap, :province, :city, :state, :phone])
    end
end
