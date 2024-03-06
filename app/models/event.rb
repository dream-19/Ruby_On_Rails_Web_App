class Event < ApplicationRecord
  #validation of the event
  validates :name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province, :state, presence: true
  validates :beginning_time, :ending_time, format: { with: /\A\d{2}:\d{2}\z/, message: "must be in the format HH:MM" }
  validates :beginning_date, :ending_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }

  belongs_to :user

  # An event can have many users subscribe to it
  has_many :subscriptions, dependent: :destroy
 
  # Through subscriptions, an event can have many subscribers (users)
  has_many :subscribers, through: :subscriptions, source: :user
end
