class Subscription < ApplicationRecord
  validates :user_id, uniqueness: { scope: :event_id, message: "You are already subscribed to this event" } # A user can subscribe to an event only once
  
  #Relationship
  belongs_to :user
  belongs_to :event



end
