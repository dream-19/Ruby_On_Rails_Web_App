# spec/features/user_registrations_spec.rb
require 'rails_helper'

RSpec.feature "UserRegistrations", type: :feature do
  scenario "Normal user registers successfully" do
    visit new_user_registration_path(user_type: UserRoles::USER_NORMAL)

    fill_in "Name", with: "Test name"
    fill_in "Surname", with: "Test Surname"
    fill_in "Date of Birth", with: "01/01/1990"
    fill_in "Email", with: "testuser@example.com"
    fill_in "password", with: "securepassword"
    fill_in "password-confirmation", with: "securepassword"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  scenario "User organizer registers successfully" do
    visit new_user_registration_path(user_type: UserRoles::USER_ORGANIZER)

    fill_in "Name", with: "Test name"
    fill_in "Surname", with: "Test Surname"
    fill_in "Date of Birth", with: "01/01/1990"
    fill_in "Phone", with: "123456789"
    fill_in "Email", with: "testuser@example.com"
    fill_in "password", with: "securepassword"
    fill_in "password-confirmation", with: "securepassword"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  scenario "Company organizer registers successfully" do
    visit new_user_registration_path(user_type: UserRoles::COMPANY_ORGANIZER)

    fill_in "Name", with: "Test name"
    fill_in "Phone", with: "123456789"
    fill_in "Email", with: "testuser@example.com"
    fill_in "password", with: "securepassword"
    fill_in "password-confirmation", with: "securepassword"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  scenario "User fails to register with mismatched passwords" do
    visit new_user_registration_path(user_type: UserRoles::COMPANY_ORGANIZER)

    fill_in "Name", with: "Test name"
    fill_in "Phone", with: "123456789"
    fill_in "Email", with: "testuser@example.com"
    fill_in "password", with: "securepassword"
    fill_in "password-confirmation", with: "securepassword1"
    click_button "Sign up"

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

 
end
