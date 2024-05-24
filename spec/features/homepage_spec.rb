# spec/features/event_management_spec.rb
require 'rails_helper'

RSpec.feature "UserSubscribe", type: :feature do
  let(:organizer) { create(:user_organizer) }
  let(:event) { create(:event, user: organizer, name: "test", max_participants: 100, beginning_date: Date.tomorrow, ending_date: 1.month.from_now) }
  let(:event2) { create(:event, user: organizer, name: "Overlap", max_participants: 100, beginning_date: Date.tomorrow, ending_date: 1.week.from_now) }
  let(:normal) { create(:user_normal)}
 

  before do
    login_as(normal, scope: :user)
  end

  scenario "User Find the 2 events listed in the homepage" do
    visit root_path

    puts page.html

    expect(page).to have_content(event.name)
    expect(page).to have_content(event2.name)
  end

 
end
