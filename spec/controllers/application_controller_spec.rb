require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      render plain: "Hello, World!"
    end

    def test
      handle_unknown_route
    end
  end
  # Define a route for the anonymous controller action
  before do
    routes.draw { get "test" => "anonymous#test" }
  end

  describe "GET #test (handle_unknown_route)" do
    it "sets a flash message and redirects to the root path" do
      get :test
      expect(flash[:alert]).to eq("The page you requested does not exist.")
      expect(response).to redirect_to(root_path)
    end
  end

  # Mock the Devise helper methods if they're needed
  before do
    # Ensure the controller behaves as a Devise controller
    allow(controller).to receive(:devise_controller?).and_return(true)
    # Prepare the parameter sanitizer mock
    allow(controller).to receive(:devise_parameter_sanitizer).and_return(double("Devise::ParameterSanitizer").as_null_object)
  end

  describe "Devise parameter sanitization" do
    it "configures additional sign up parameters" do
      expect(controller.devise_parameter_sanitizer).to receive(:permit).with(:sign_up, keys: [:name, :surname, :date_of_birth, :address, :cap, :province, :city, :country, :phone, :type])
      controller.send(:configure_permitted_parameters)
    end

    it "configures additional account update parameters" do
      expect(controller.devise_parameter_sanitizer).to receive(:permit).with(:account_update, keys: [:name, :surname, :date_of_birth, :address, :cap, :province, :city, :country, :phone])
      controller.send(:configure_permitted_parameters)
    end
  end
  describe "#after_sign_in_path_for" do
    let(:user) { create(:user_normal) }
    let(:organizer) { create(:user_organizer) }

    it "redirects to my events page if user is an organizer" do
      sign_in organizer
      expect(controller.send(:after_sign_in_path_for, organizer)).to eq(my_events_path)
    end

    it "redirects to root path if user is not an organizer" do
      sign_in user
      expect(controller.send(:after_sign_in_path_for, user)).to eq(root_path)
    end
  end
end
