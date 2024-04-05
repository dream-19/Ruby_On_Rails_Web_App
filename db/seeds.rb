# db/seeds.rb

require 'factory_bot_rails'

# Clear existing data
puts 'Deleting existing data...'
User.destroy_all
Event.destroy_all
Subscription.destroy_all
Notification.destroy_all

# Insert new data
puts 'Inserting new data...'


# Create specific user subclasses if needed
10.times do
  user = FactoryBot.create(:user_normal)
end

user1 = FactoryBot.create(:user_normal, email: "test1@gmail.com")
user2 = FactoryBot.create(:user_normal, email: "test2@gmail.com")

5.times do
  user = FactoryBot.create(:user_organizer)
  3.times do
     event = FactoryBot.create(:event, user: user) 
      sub = FactoryBot.create(:subscription, user: user1, event: event)
  end
end

5.times do
  user = FactoryBot.create(:company_organizer)
  2.times do
    event = FactoryBot.create(:event, user: user) 
    sub = FactoryBot.create(:subscription, user: user2, event: event)
  end
end

