# spec/factories/events.rb
FactoryBot.define do
  factory :event do
    association :user, factory: :user_organizer # Default to UserOrganizer
    name { Faker::Lorem.words(number: 4).join(" ") }
    beginning_date { Faker::Date.forward(from: Date.today ).strftime("%Y-%m-%d") }
    ending_date { beginning_date.to_date + Faker::Number.between(from: 1, to: 300).days } # Ensures ending_date is after beginning_date
    beginning_time { Faker::Time.between(from: Time.parse("00:00"), to: Time.parse("23:59")).strftime("%H:%M") }
    ending_time { Faker::Time.between(from: (beginning_time.to_time + 1.minute), to: Time.parse("23:59")).strftime("%H:%M") }
    max_participants { Faker::Number.between(from: 1, to: 100) }
    address { Faker::Address.street_address }
    cap { Faker::Address.zip_code }
    province { Faker::Address.state }
    city { Faker::Address.city }
    country { Faker::Address.country }
    description { Faker::Lorem.paragraph_by_chars(number: Faker::Number.between(from: 1, to: 500)) if Faker::Boolean.boolean } # Optional field, limited to 500 charactersend
  end
end
