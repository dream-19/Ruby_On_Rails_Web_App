# db/seeds.rb

require "factory_bot_rails"

# Clear existing data
puts "Deleting existing data..."
User.destroy_all
Event.destroy_all
Subscription.destroy_all
Notification.destroy_all

# Insert new data
puts "Inserting new data..."

# Create specific user subclasses if needed
10.times do
  user = FactoryBot.create(:user_normal)
end

user_normal1 = FactoryBot.create(:user_normal, email: "test1@gmail.com")
user_normal2 = FactoryBot.create(:user_normal, email: "test2@gmail.com")
user_organizer1 = FactoryBot.create(:user_organizer, email: "admin1@gmail.com")
user_organizer2 = FactoryBot.create(:user_organizer, email: "admin2@gmail.com")

5.times do
  user = FactoryBot.create(:user_organizer)
  5.times do
    event = FactoryBot.create(:event, user: user)
    
  end
end

5.times do
  user = FactoryBot.create(:company_organizer)
  6.times do
    event = FactoryBot.create(:event, user: user)
  end
end

# create events
event0 = FactoryBot.create(:event, user: user_organizer1, beginning_date: 10.day.ago, ending_date: 2.days.from_now)
event01 = FactoryBot.create(:event, user: user_organizer1, beginning_date: 3.day.ago, ending_date: 20.days.from_now)
event02 = FactoryBot.create(:event, user: user_organizer1, beginning_date: 1.day.ago, ending_date: 1.day.from_now)
event1 = FactoryBot.create(:event, user: user_organizer1, beginning_date: 1.day.ago, ending_date: 1.day.from_now, max_participants: 2)
event2 = FactoryBot.create(:event, user: user_organizer1, beginning_date: 2.day.from_now, ending_date: 7.days.from_now)
event3 = FactoryBot.create(:event, user: user_organizer2, beginning_date: 2.days.from_now, ending_date: 3.days.from_now)
event4 = FactoryBot.create(:event, user: user_organizer2, beginning_date: 1.month.from_now, ending_date: 2.month.from_now)
event_past  = Event.new(
  name: "Event",
  max_participants: 10,
  beginning_date: 2.days.ago,
  ending_date: 1.day.ago,
  beginning_time: "10:00",
  ending_time: "12:00",
  address: "Address",
  cap: "City",
  country: "Country",
  province: "Province",
  city: "City",
  user: user_organizer1,
)
event_past.save(validate: false)


sub = FactoryBot.create(:subscription, user: user_normal1, event: event1)
sub = FactoryBot.create(:subscription, user: user_normal1, event: event2)
sub = FactoryBot.create(:subscription, user: user_normal1, event: event4)
sub = FactoryBot.create(:subscription, user: user_normal2, event: event1)
sub = FactoryBot.create(:subscription, user: user_normal2, event: event3)

sub_past = Subscription.new(
  user: user_normal1,
  event: event_past,
)

sub_past.save(validate: false)

sub_past2 = Subscription.new(
  user: user_normal2,
  event: event_past,
)
sub_past2.save(validate: false)
