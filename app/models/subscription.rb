class Subscription < ApplicationRecord
  validates :user_id, uniqueness: { scope: :event_id, message: "You are already subscribed to this event" } # A user can subscribe to an event only once

  validate :check_overlap
  validate :check_event_and_user

  #Relationship
  belongs_to :user
  belongs_to :event

  after_save :generate_notifications_sub
  after_save :generate_notifications_check_capacity

  # Create a notification when a user unsubscribes from an event (or when it is removed from the owner of the event)
  def destroy_with_user(current_user)
    if current_user.organizer?
      # Organizer-specific logic
      NotificationService.create_notification_remove_user(user: user, event: event, user_organizer: event.user)
    else
      # Non-organizer logic
      NotificationService.create_notification_unsubscribe(user: user, event: event, user_organizer: event.user)
    end

    destroy
  end

  # Check if the event overlaps with another event that the user is already subscribed to
  def check_overlap
    event_start = DateTime.parse("#{event.beginning_date} #{event.beginning_time}")
    event_end = DateTime.parse("#{event.ending_date} #{event.ending_time}")

    if user.subscribed_events.any? do |e|
      subscribed_event_start = DateTime.parse("#{e.beginning_date} #{e.beginning_time}")
      subscribed_event_end = DateTime.parse("#{e.ending_date} #{e.ending_time}")

      # Check if the events overlap (start of the new event is between the start and end of the subscribed event, or the end of the new event is between the start and end of the subscribed event)
      if event_start.between?(subscribed_event_start, subscribed_event_end) ||
         event_end.between?(subscribed_event_start, subscribed_event_end) ||
         subscribed_event_start.between?(event_start, event_end) ||
         subscribed_event_end.between?(event_start, event_end)
        errors.add(:base, "You are already subscribed to an event that overlaps with this event: #{e.name}")
        
        return false
      end
    end
    end
    return true
  end

  #When the user try to subscribe to an event:
  # check if the user is a normal user
  # check if the user is already subscribed to the event
  # check if the event is not a past event
  # chek if the event is already full
  def check_event_and_user
    if user.organizer?
      errors.add(:base, "You are an organizer and cannot subscribe to events")
      
      return false
    end

    if event.full?
      errors.add(:base, "The event is already full")
      
      return false
    end

    if event.past?
      errors.add(:base, "The event has already passed")
      
      return false
    end

    if user.subscribed_events.include?(event)
      errors.add(:base, "You are already subscribed to this event")
      
      return false
    end
    return true
  end

  private

  # Create a notification when a user subscribes to an event
  def generate_notifications_sub
    NotificationService.create_notification_subscribe(user: user, event: event, user_organizer: event.user)
  end

  # Create a notification when the event reaches full capacity
  def generate_notifications_check_capacity
    if event.full?
      NotificationService.create_notification_full_capacity(user_organizer: event.user, event: event)
    end
  end
end
