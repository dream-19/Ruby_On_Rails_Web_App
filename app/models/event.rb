class Event < ApplicationRecord
  belongs_to :user

  # An event can have many users subscribe to it
  has_many :subscriptions, dependent: :destroy
 
  # Through subscriptions, an event can have many subscribers (users)
  has_many :subscribers, through: :subscriptions, source: :user
end
