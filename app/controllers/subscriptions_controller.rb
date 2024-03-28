class SubscriptionsController < ApplicationController
        before_action :authenticate_user! # Assuming you're using Devise for user authentication
        before_action :check_user, only: [:create]

    def create
        event = Event.find(params[:event_id]) # Find the event that the user wants to subscribe to
        subscription_date = Date.current
        subscription_time = Time.current.strftime("%H:%M")

        subscription = current_user.subscriptions.build(event: event, subscription_date: subscription_date, subscription_time: subscription_time) # Create a new subscription
      
        # No need for a successful message (it is already shown in the view)
        unless subscription.save
            flash[:alert] = "There was an issue subscribing to the event: #{subscription.errors.full_messages.join(', ')}"

        end
        redirect_to event_path(event) # Redirect back to the event's page
    end

    private

    #When the user try to subscribe to an event:
        # check if the user is a normal user
        # check if the user is already subscribed to the event
        # check if the event is not a past event
        # check if the user isn't already subscribed to another event at the same time
        # chek if the event is already full
    def check_user
        event = Event.find(params[:event_id])
        if !current_user.normal?
            flash[:alert] = "You must be a normal user to subscribe to an event."
            redirect_to event_path(event)
        elsif current_user.subscribed_events.include?(event)
            flash[:alert] = "You are already subscribed to this event."
            redirect_to event_path(event)
        elsif event.subscribers.count >= event.max_participants
            flash[:alert] = "This event is already full."
            redirect_to event_path(event)
        elsif event.ending_date < Date.today
            flash[:alert] = "This event has already passed."
            redirect_to event_path(event)
        # TODO: check if there is an event at the same time (check beginning/ending date and beginning time and ending time)
        elsif current_user.subscribed_events.any? { |e| e.beginning_date == event.beginning_date && e.ending_date == event.ending_date && e.beginning_time == event.beginning_time && e.ending_time == event.ending_time }
            flash[:alert] = "You are already subscribed to an event at the same time."
            redirect_to event_path(event)
        end
    end

end
