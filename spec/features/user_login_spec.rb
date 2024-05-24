require 'rails_helper'

RSpec.feature "UserLogin", type: :feature do
  let(:user) { create(:user_normal) }

  scenario "User logs in successfully" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_text("Signed in successfully.")
  end

  scenario "User fails to login with wrong credentials" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end

  scenario "User edits profile successfully" do
    login_as(user, scope: :user)

    visit edit_user_registration_path

    fill_in "Email", with: "newemail@coso.it"
    fill_in "current-password", with: user.password
    click_button "Update"

    expect(page).to have_text("Your account has been updated successfully.")
  end

  scenario "User fails to edit profile with wrong credentials" do
    login_as(user, scope: :user)

    visit edit_user_registration_path

    fill_in "Email", with: "newemail@edit.it"
    fill_in "current-password", with: "wrongpassword"
    click_button "Update"

    expect(page).to have_text("Current password is invalid")
  end

  scenario "User logout successfully" do
    login_as(user, scope: :user)

    visit root_path
    click_button "Sign out"

    expect(page).to have_text("Signed out successfully.")
  end
end
