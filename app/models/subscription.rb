class Subscription < ApplicationRecord
  validates :user_id, uniqueness: { scope: :event_id, message: "You are already subscribed to this event" } # A user can subscribe to an event only once
  
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
      Rails.logger.debug("GALLINE CON UOVA")
    else
      # Non-organizer logic
      NotificationService.create_notification_unsubscribe(user: user, event: event, user_organizer: event.user)
    end

    destroy
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
