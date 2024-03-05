class User < ApplicationRecord
  # An organizer can create many events
  has_many :events, dependent: :destroy

  # Users can have many subscriptions to events
  has_many :subscriptions, dependent: :destroy

  # Through subscriptions, users can subscribe to many events
  has_many :subscribed_events, through: :subscriptions, source: :event
end
