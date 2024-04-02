class Subscription < ApplicationRecord
  validates :user_id, uniqueness: { scope: :event_id, message: "You are already subscribed to this event" } # A user can subscribe to an event only once
  
  #Relationship
  belongs_to :user
  belongs_to :event

  after_destroy :generate_notifications_uns
  after_save :generate_notifications_sub

  private

  # Create a notification when a user unsubscribes from an event (or when it is removed from the owner of the event)
  def generate_notifications_uns
    Rails.logger.debug("galline")
    Rails.logger.debug(user)
    Rails.logger.debug(user.organizer?)
    Rails.logger.debug(current_user)
    if user.organizer?
      Rails.logger.debug("ABAAAAAAAAAAAAAUser is the owner of the event")
      NotificationService.create_notification_remove_user(user: user, event: event, user_organizer: event.user)
    else
      Rails.logger.debug("ABBBBBBBBBBBBBBBBB")
      NotificationService.create_notification_unsubscribe(user: user, event: event, user_organizer: event.user)
    end
  end

  # Create a notification when a user subscribes to an event
  def generate_notifications_sub
    NotificationService.create_notification_subscribe(user: user, event: event, user_organizer: event.user)
  end
end
