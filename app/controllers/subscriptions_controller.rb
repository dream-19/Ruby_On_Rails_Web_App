class SubscriptionsController < ApplicationController
  before_action :authenticate_user! # Assuming you're using Devise for user authentication

  def create
    event = Event.find(params[:event_id]) # Find the event that the user wants to subscribe to
    subscription = current_user.subscriptions.build(event: event) # Create a new subscription

    # No need for a successful message (it is already shown in the view)
    unless subscription.save
      flash[:alert] = subscription.errors.full_messages.join(", ")
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
end
