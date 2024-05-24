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

  scenario "User clicks on 'see all' and visits the page with all notifications" do 
    create(:event, name: "Event 1", user: organizer)
    create(:notification, user: user, event: Event.first, message: "Your Notification")
    create(:notification, user: user, event: Event.first, message: "Your Notification 2")

    visit root_path

    click_link "See all"

    expect(page).to have_content("Your Notification")

    #expect to have 2 unread notifications
    within('button.btn.bg-gradient-primary') do
        expect(find('span.badge.rounded-pill.bg-light.text-dark.ms-2')).to have_text('2')
      end

    #expect to have 0 read notifications
    within('button.btn.bg-gradient-secondary') do
        expect(find('span.badge.rounded-pill.bg-light.text-dark.ms-2')).to have_text('0')
      end

    click_link "Mark All as Read"
    expect(page).to have_content("All notifications marked as read.")

    #expect to have 0 unread notifications
    within('button.btn.bg-gradient-primary') do
        expect(find('span.badge.rounded-pill.bg-light.text-dark.ms-2')).to have_text('0')
      end

    #expect to have 2 read notifications
    within('button.btn.bg-gradient-secondary') do
        expect(find('span.badge.rounded-pill.bg-light.text-dark.ms-2')).to have_text('2')
      end

  end

 
end
