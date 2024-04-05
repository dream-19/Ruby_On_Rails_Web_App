# db/seeds.rb

require 'factory_bot_rails'


# Create specific user subclasses if needed
10.times do
  FactoryBot.create(:user_normal)
end

5.times do
  user = FactoryBot.create(:user_organizer)
  3.times do
    FactoryBot.create(:event, user: user) 
  end
end

5.times do
  user = FactoryBot.create(:company_organizer)
  2.times do
    FactoryBot.create(:event, user: user) 
  end
end

