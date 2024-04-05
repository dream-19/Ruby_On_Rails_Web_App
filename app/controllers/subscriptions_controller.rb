class SubscriptionsController < ApplicationController
        before_action :authenticate_user! # Assuming you're using Devise for user authentication
        before_action :check_user, only: [:create]
        before_action :check_overlaps, only: [:create]


    def create
        event = Event.find(params[:event_id]) # Find the event that the user wants to subscribe to
        subscription = current_user.subscriptions.build(event: event) # Create a new subscription
      
        # No need for a successful message (it is already shown in the view)
        unless subscription.save
            flash[:alert] = "There was an issue subscribing to the event: #{subscription.errors.full_messages.join(', ')}"
        end
        
        redirect_to event_path(event) # Redirect back to the event's page
    end

    # Destroy: unsubscribe from an event (made by the user who subscribed to the event)
    def destroy
        subscription = current_user.subscriptions.find(params[:id])
        event = subscription.event

        # Check if the user is the owner of the subscription or the event
        if current_user == subscription.user || current_user == event.user
            subscription.destroy_with_user(current_user) if subscription.present?
           
            flash[:notice] = "You have unsubscribed from the event: #{event.name}"
     
        else
            flash[:alert] = "You are not authorized to unsubscribe from this event."
        end

        redirect_back(fallback_location: events_path) 
    end

    # BULK destroy: multiple subscriptions (made by the event owner or the user who subscribed to the event)
    # This method is called when the user clicks on the "Unsubscribe" button in the "My Subscriptions" page
    # or when the event owner wants to remove the subscriptions of multiple users
    def bulk_destroy_sub
        sub_ids = params[:sub_ids]
        sub_ids.each do |sub_id|
            subscription = Subscription.find_by(id: sub_id)
            if subscription.nil?
                message = "Subscription not found."
                render json: { success: false, message: message }, status: :not_found
                return
            end
            event = subscription.event
            if current_user == event.user || current_user == subscription.user
                subscription.destroy_with_user(current_user) if subscription.present?
            else 
                message = "You are not authorized to unsubscribe from this event."
                render json: { success: false, message: message }, status: :unauthorized
                return
            end
        end 
        flash[:notice] = "Subscriptions Deleted Successfully."
        render json: { success: true }
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

        # Check if the user is already subscribed to an event that overlaps with the new event
        if current_user.subscribed_events.any? do |e|
            subscribed_event_start = DateTime.parse("#{e.beginning_date} #{e.beginning_time}")
            subscribed_event_end = DateTime.parse("#{e.ending_date} #{e.ending_time}")

            # Check if the events overlap (start of the new event is between the start and end of the subscribed event, or the end of the new event is between the start and end of the subscribed event)
           if  event_start.between?(subscribed_event_start, subscribed_event_end) || 
               event_end.between?(subscribed_event_start, subscribed_event_end) ||
                subscribed_event_start.between?(event_start, event_end) ||
                subscribed_event_end.between?(event_start, event_end)
            
                flash[:alert] = "You are already subscribed to an event that overlaps with this time: #{e.name}"
                redirect_to event_path(event)
           end
        end
        end
    end

end