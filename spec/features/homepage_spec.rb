# spec/features/events_display_spec.rb
require 'rails_helper'

RSpec.feature "Homepage", type: :feature do
  let(:user) { create(:user_normal) }
  let(:organizer)  { create(:user_organizer) }

  before do
    Capybara.current_driver = :rack_test # To avoid errors with the default driver: selenium_chrome_headless
    login_as(user, scope: :user)
  end

  scenario "User sees existing events" do
    create(:event, name: "Event 1", user: organizer)
    create(:event, name: "Event 2", user: organizer)

    visit root_path

    expect(page).to have_content("Event 1")
    expect(page).to have_content("Event 2")
  end

  scenario "User sees 'no events' message when there are no events" do
    visit root_path

    expect(page).to have_content("There are no events to display")
  end

 
end
