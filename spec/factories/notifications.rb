FactoryBot.define do
    factory :notification do
        message { Faker::Lorem.sentence }
        notification_type { "info" }
        read { false }
        event { nil } 
        association :user
    end
end