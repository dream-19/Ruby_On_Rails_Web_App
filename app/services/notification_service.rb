class NotificationService
    # Create a notification: when a user subscribes to an event (owner and subscriber)
    def self.create_notification_subscribe(user:, event: , user_organizer:)
      # For the user who subscribed to the event
      Notification.create!(
        user: user,
        event: event,
        read: false,
        message: "You have subscribed to the event: #{event.name}",
        notification_type: "event_subscription"
      )

      # For the event owner
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "#{user.name} #{user.surname} (email: #{user.email}) has subscribed to your event: #{event.name}",
            notification_type: "event_subscription"
        )
    end

    # Create a notification: when a user unsubscribes from an event (owner and subscriber)
    def self.create_notification_unsubscribe(user:, event: , user_organizer:)
        # For the user who unsubscribed from the event
        Notification.create!(
            user: user,
            event: event,
            read: false,
            message: "You have unsubscribed from the event: #{event.name}",
            notification_type: "user_unsubscribe"
        )

        # For the event owner
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "#{user.name} #{user.surname} (email: #{user.email}) has unsubscribed from your event: #{event.name}",
            notification_type: "user_unsubscribe"
        )
  end

  # Create a notification: when a user unsubscribes from an event because it deletes his account
  def self.create_notification_unsubscribe_delete(user:, event: , user_organizer:)
    # For the event owner
    Notification.create!(
        user: user_organizer,
        event: event,
        read: false,
        message: "#{user.name} #{user.surname} (email: #{user.email}) has unsubscribed from your event: #{event.name} (account deleted)",
        notification_type: "user_unsubscribe"
    )
end


  #Create a notification: the owner of an event removes a user from the event
    def self.create_notification_remove_user(user:, event: , user_organizer:)
        # For the user who was removed from the event
        Notification.create!(
            user: user,
            event: event,
            read: false,
            message: "You have been removed from the event: #{event.name}",
            notification_type: "user_removed"
        )

        # For the event owner
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "#{user.name} #{user.surname} (email: #{user.email}) has been removed from your event: #{event.name}",
            notification_type: "user_removed"
        )
    end

    # Create a notification: when a user creates an event
    def self.create_notification_create_event(user_organizer:, event:)
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "You have created the event: #{event.name}",
            notification_type: "event_create"
        )
    end

    # Create a notification: when a user updates an event
    #the update_message contains the significant changes made to the event (description, photos are not included)
    # if not significant changes are made, the update_message is empty
    # if no changes are made the notification isn't sent
    def self.create_notification_update_event(user_organizer:, event:, update:)
        # For the event owner
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "You have updated the event: #{event.name}",
            notification_type: "event_update"
        )

        #For every user subscribed
        event.subscriptions.each do |subscription|
            Notification.create!(
                user: subscription.user,
                event: event,
                read: false,
                message: "The event: #{event.name} has been updated. #{update}",
                notification_type: "event_update"
            )
        end
    end

    # Create a notification: when a user deletes an event
    def self.create_notification_delete_event(user_organizer:, event:)
        Notification.create!(
            user: user_organizer,
            read: false,
            message: "You have deleted the event: #{event.name}",
            notification_type: "event_delete"
        )

         #For every user subscribed
         event.subscriptions.each do |subscription|
            Notification.create!(
                user: subscription.user,
                read: false,
                message: "The event: #{event.name} has been deleted",
                notification_type: "event_delete"
            )
        end

    end


    # Create a notification: when an event reaches full capacity
    def self.create_notification_full_capacity(user_organizer:, event:)
        Notification.create!(
            user: user_organizer,
            event: event,
            read: false,
            message: "The event: #{event.name} has reached full capacity",
            notification_type: "event_full_capacity"
        )
    end
end