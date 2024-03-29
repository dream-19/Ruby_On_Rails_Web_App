class SubscriptionsController < ApplicationController
        before_action :authenticate_user! # Assuming you're using Devise for user authentication
        before_action :check_user, only: [:create]
        before_action :check_overlaps, only: [:create]

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

    def destroy
        subscription = current_user.subscriptions.find(params[:id])
        event = subscription.event

        # Check if the user is the owner of the subscription or the event
        if current_user == subscription.user || current_user == event.user
            subscription.destroy
            flash[:notice] = "You have unsubscribed from the event: #{event.name}"
        else
            flash[:alert] = "You are not authorized to unsubscribe from this event."
        end

        redirect_back(fallback_location: events_path) 
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
        elsif current_user.subscribed?(event)
            flash[:alert] = "You are already subscribed to this event."
        elsif event.full?
            flash[:alert] = "This event is already full."
        elsif event.past?
            flash[:alert] = "This event has already passed."
 
        else 
            return true
        end
        redirect_to event_path(event)
    end

    def check_overlaps
        event = Event.find(params[:event_id])
        event_start = DateTime.parse("#{event.beginning_date} #{event.beginning_time}")
        event_end = DateTime.parse("#{event.ending_date} #{event.ending_time}")

        if current_user.events.any? do |e|
            subscribed_event_start = DateTime.parse("#{e.beginning_date} #{e.beginning_time}")
            subscribed_event_end = DateTime.parse("#{e.ending_date} #{e.ending_time}")

            # Check if the events overlap (start of the new event is between the start and end of the subscribed event, or the end of the new event is between the start and end of the subscribed event)
           if  (event_start < subscribed_event_end && event_start > subscribed_event_start) || (event_end < subscribed_event_end && event_end > subscribed_event_start) 
                flash[:alert] = "You are already subscribed to an event that overlaps with this time: #{e.name}"
                redirect_to event_path(event)
           end
        end
        end
    end

end