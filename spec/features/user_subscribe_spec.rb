# spec/features/event_management_spec.rb
require 'rails_helper'

RSpec.feature "UserSubscribe", type: :feature do
  let(:organizer) { create(:user_organizer) }
  let(:event) { create(:event, user: organizer, name: "test", max_participants: 100, beginning_date: Date.tomorrow, ending_date: 1.month.from_now) }
  let(:event2) { create(:event, user: organizer, name: "Overlap", max_participants: 100, beginning_date: Date.tomorrow, ending_date: 1.week.from_now) }
  let(:normal) { create(:user_normal)}
 

  before do
    # Devise is used for authentication
    login_as(normal, scope: :user)
  end

  scenario "User subscibe to the event" do
    visit event_path(event)

    click_button "Subscribe"
    expect(page).to have_content("You are subscribed to this event!")
  end

 scenario "User unsubscribe from the event" do
    visit event_path(event)

   click_button "Subscribe"

    click_link "Unsubscribe"
    modal_id = "#deleteSubscription#{event.id}"
    within(modal_id) do
        click_link "Yes Unsubscribe"
    end

    expect(page).to have_content("You have unsubscribed from the event: #{event.name}")
  end

  scenario "User fails to subscribe to an overlapping event" do
    visit event_path(event)

    click_button "Subscribe"
    expect(page).to have_content("You are subscribed to this event!")

    visit event_path(event2)

    click_button "Subscribe"
    expect(page).to have_content("You are already subscribed to an event that overlaps with this event: #{event.name}")
  end
 
end
