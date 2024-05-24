# spec/features/event_management_spec.rb
require 'rails_helper'

RSpec.feature "EventManagement", type: :feature do
  let(:organizer) { create(:user_organizer) }
  let(:event) { create(:event, user: organizer, name: "test", max_participants: 100) }
  let(:normal) { create(:user_normal)}
 

  before do
    # Devise is used for authentication
    login_as(organizer, scope: :user)
  end

  scenario "Organizer creates a new event successfully" do
    visit new_event_path

    fill_in "Event Name", with: "Tech Conference"
    fill_in "Max Partecipants", with: 10
    fill_in "Beginning Date", with: (Time.zone.now + 1.week).strftime("%Y-%m-%d")
    fill_in "Ending Date", with: (Time.zone.now + 1.week + 2.days).strftime("%Y-%m-%d")
    fill_in "Beginning Time", with: "09:00"
    fill_in "Ending Time", with: "17:00"
    fill_in "user_country", with: "United States"
    fill_in "user_city", with: "New York"
    fill_in "user_cap", with: "45023"
    fill_in "user_province", with: "New York"
    fill_in "Address", with: "Convention Center"

    click_button "Create Event"

    expect(page).to have_content("Event was successfully created.")
    expect(page).to have_content("Tech Conference")
  end

  scenario "Organizer fails to create a new event (event name field missing)" do
    visit new_event_path

    fill_in "Max Partecipants", with: 10
    fill_in "Beginning Date", with: (Time.zone.now + 1.week).strftime("%Y-%m-%d")
    fill_in "Ending Date", with: (Time.zone.now + 1.week + 2.days).strftime("%Y-%m-%d")
    fill_in "Beginning Time", with: "09:00"
    fill_in "Ending Time", with: "17:00"
    fill_in "user_country", with: "United States"
    fill_in "user_city", with: "New York"
    fill_in "user_cap", with: "45023"
    fill_in "user_province", with: "New York"
    fill_in "Address", with: "Convention Center"

    click_button "Create Event"

    expect(page).to have_content("Name can't be blank")
  end

  scenario "Organizer edits an event successfully" do
    visit edit_event_path(event)

    fill_in "Name", with: "Updated Tech Conference"
    click_button "Save Changes"

    expect(page).to have_content("Event was successfully updated.")
    expect(page).to have_content("Updated Tech Conference")
  end

  scenario "Organizer fails to edit event (name can't be blank)" do
    visit edit_event_path(event)

    fill_in "Name", with: ""
    click_button "Save Changes"

    expect(page).to have_content("Name can't be blank")
  end

  

  scenario "Organizer deletes event successfully" do 
    visit event_path(event)

    click_link "Delete" #trigger modal
    id_modal = '#deleteEvent' + event.id.to_s
    within(id_modal) do  
      click_link 'Confirm Deletion' 
    end

    expect(page).to have_content("Event was successfully destroyed.")
  end

  
 
end
