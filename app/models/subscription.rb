class Subscription < ApplicationRecord
  #validation of the subscription
  validates :subscription_time, :subscription_date, presence: true
  #subscription time must be in a time format
  validates :subscription_time, format: { with: /\A\d{2}:\d{2}\z/, message: "must be in the format HH:MM" }
  #subscription date must be in a date format
  validates :subscription_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }

  belongs_to :user
  belongs_to :event
end
