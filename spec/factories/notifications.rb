FactoryBot.define do
    factory :notification do
        message { Faker::Lorem.sentence }
        notification_type { "info" }
        read { false }
        event { nil } # the event associated is optional
 
        association :user
    end
end