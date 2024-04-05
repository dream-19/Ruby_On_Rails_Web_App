# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number_with_country_code }
    address { Faker::Address.street_address }
    cap { Faker::Address.zip_code }
    province { Faker::Address.state }
    city { Faker::Address.city }
    country { Faker::Address.country }
    password { "ciao123" }
    password_confirmation { "ciao123" }
  end 

    # Subclass for CompanyOrganizer
    factory :company_organizer, parent: :user  do
      type { "CompanyOrganizer" }
    end

    # Subclass for UserOrganizer
    factory :user_organizer, parent: :user  do
      type { "UserOrganizer" }
      date_of_birth { Faker::Date.between(from: "1980-01-01", to: "2010-12-31").to_s }
      surname { Faker::Name.last_name } 
    end

    # Subclass for UserNormal
    factory :user_normal, parent: :user  do
      type { "UserNormal" }
      date_of_birth { Faker::Date.between(from: "1980-01-01", to: "2010-12-31").to_s }
      surname { Faker::Name.last_name } 
    end
  end

