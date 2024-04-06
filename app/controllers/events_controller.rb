class EventsController < ApplicationController
  #check Authentication
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  # Check if the user in an organizer to access this functions
  before_action :check_organizer_role, only: [:new, :create, :edit, :update, :destroy, :my_events, :bulk_destroy, :delete_photo, :data]
  before_action :check_owner, only: [:edit, :update, :destroy]

  # GET /events
  def index
    #Log the params of the requests
    Rails.logger.debug("AIAAAAAAAAA")
    Rails.logger.debug("Params: #{params}")
    pagination_par = 18
    begin
      @events = Event.upcoming

      if params[:order_by].present?

        #check if the user want to see only his events
        if params[:my_events].present?
          if user_signed_in?
            @events = current_user.organizer? ? current_user.created_events : current_user.subscribed_events
            @events = @events.upcoming
          else
            @events = Event.none
          end
        end

        #ORDERING
        direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
        #sanitize input
        params[:order_by] = Event.column_names.include?(params[:order_by]) ? params[:order_by] : "beginning_date"
        if params[:order_by] == "organizer"
          @events = @events.joins(:user).order("users.name " + direction)
        elsif params[:order_by] == "participants"
          @events = direction == "asc" ? @events.left_joins(:subscriptions).group("events.id").order("COUNT(subscriptions.id) ASC") : @events.left_joins(:subscriptions).group("events.id").order("COUNT(subscriptions.id) DESC")
        elsif params[:order_by] == "beginning_date" || params[:order_by] == "ending_date"
          @events = @events.order(params[:order_by] + " " + direction + ", beginning_time " + direction)
        else
          #Normal case with order
          @events = @events.order(params[:order_by] + " " + direction)
        end

        # Check if the user wants to see only ongoing events
        if params[:on_going].present?
          @events = @events.ongoing
        end

        # Check if the user wants to see not fully events
        if params[:not_full].present?
          @events = @events.notfull
        end

        # SEARCH is present (normal search or interval search)
        if params[:search_by].present? and (params[:search].present? || params[:from_date].present? || params[:to_date].present?)
          # special cases (organizer, date)
          if params[:search_by] == "organizer" # organizer can be name + surname
            @events = @events.joins(:user).where('CONCAT(users.name,\' \',users.surname) LIKE ?', "%" + params[:search] + "%") # ? to sanitaze input
          elsif params[:search_by] == ("beginning_date" || "ending_date")
            #TODO
            date = iso_date(params[:search])
            @events = @events.where(params[:search_by] + " LIKE ?", "%" + date + "%")
          elsif params[:search_by] == "interval"
            from_date = params[:from_date]
            to_date = params[:to_date]

            if from_date.present? && to_date.present?
              @events = @events.where("beginning_date >= ? AND ending_date <= ?", from_date, to_date)
            elsif from_date.present?
              @events = @events.where("beginning_date >= ?", from_date)
            else
              @events = @events.where("ending_date <= ?", to_date)
            end
          else
            @events = @events.where(params[:search_by] + " LIKE ?", "%" + params[:search] + "%")
          end
        end
      else
        @events = @events.order(beginning_date: :asc, beginning_time: :asc)
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "Failed to fetch events: #{e.message}"
      flash[:error] = "There was a problem fetching the events."

      # Redirect or set @events to a safe default
      @events = Event.order(beginning_date: :asc).page(params[:page]).per(pagination_par)
    end

    @events = @events.page(params[:page]).per(pagination_par)


    # Respond to
    respond_to do |format|
      format.html # For regular requests
      format.js  #{ render partial: "events_list", locals: { events: @events }, layout: false } # For AJAX requests
    end
  end

  # GET /events/my_events_user (events subscribed by the current user)
  def my_events_user
    @current_sub = current_user.subscribed_events.ongoing
    @current_sub_json = format_events_as_json(@current_sub, false) #false for no edit

    @future_sub = current_user.subscribed_events.future
    @future_sub_json = format_events_as_json(@future_sub, false)

    @past_sub = current_user.subscribed_events.past
    @past_sub_json = format_events_as_json(@past_sub, false)

    render :my_subscriptions
  end

  # GET /events/my_events (events created by the current user)
  def my_events
    #ONGOING
    @current_events = current_user.created_events.ongoing
    @current_events_json = format_events_as_json(@current_events, true) #true for edit

    #FUTURE
    @future_events = current_user.created_events.future
    @future_events_json = format_events_as_json(@future_events, true) #true for edit

    #PAST
    @past_events = current_user.created_events.past
    @past_events_json = format_events_as_json(@past_events, false) #false for no edit

    render :my_events
  end

  # GET /events/data
  def data
    case params[:event_type]
    when "current"
      @current_events = current_user.created_events.ongoing.order(beginning_date: :asc)
      events_data = format_events_as_json(@current_events, true)
    when "future"
      @future_events = current_user.created_events.future
      events_data = format_events_as_json(@future_events, true) #true for edit
    when "past"
      @past_events = current_user.created_events.past.order(ending_date: :desc)
      events_data = format_events_as_json(@past_events, false)
    else
      events_data = [].to_json
    end
    render json: events_data
  end

  # GET /events/1
  def show
    @event = Event.find_by(id: params[:id])
    #if the user is the organizer of the event get also the subscribtions
    if current_user == @event.user
      @subscriptions = @event.subscriptions
      @subscriptions_json = format_subscriptions_as_json(@subscriptions)
    end

    if @event.nil?
      redirect_to events_path, alert: "Event not found."
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    # Check if the event has already ended
    if @event.past?
      redirect_to @event, alert: "You cannot edit an event that has already ended."
    end
  end

  # POST /events
  def create
    @event = current_user.created_events.build(event_params)
    if @event.save

      # Reindirizzamento in caso di successo
      redirect_to @event, notice: "Event was successfully created."
    else
      # Render della vista 'new' in caso di fallimento
      # Nota: questo render potrebbe causare l'errore se non seguito da un reindirizzamento in qualche modo.
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    # Check if the event has already ended
    if @event.ending_date < Date.today
      redirect_to @event, alert: "You cannot edit an event that has already ended."
      return
    end

    # Check if the number of participants hasn't been lowered too much
    if event_params[:max_participants].to_i < @event.subscriptions.count
      redirect_to edit_event_path(@event), alert: "The number of participants cannot be lowered below the current number of attendees: " + @event.subscriptions.count.to_s
      return
    end

    # List of changed attributes
    changed_attributes = []
    update_message = ""
    n_changes = 0
    event_params.each do |key, value|
      if @event.attributes.has_key?(key) && key != "description" && key != "photos"
        if key == "name"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "Name changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "beginning_date"
          attr = helpers.format_date(@event.attributes[key])
          val = helpers.format_date(Date.parse(value))
          if attr != val
            changed_attributes << "Beginning Date changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "ending_date"
          attr = helpers.format_date(@event.attributes[key])
          val = helpers.format_date(Date.parse(value))
          if attr != val
            changed_attributes << "Ending Date changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "beginning_time"
          attr = helpers.format_time(@event.attributes[key])
          val = Time.parse(value).strftime("%H:%M")
          if attr != val
            changed_attributes << "Beginning Time changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "ending_time"
          attr = helpers.format_time(@event.attributes[key])
          val = Time.parse(value).strftime("%H:%M")
          if attr != val
            changed_attributes << "Ending Time changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "max_participants"
          attr = @event.attributes[key]
          val = value.to_i
          if attr != val
            changed_attributes << "Max Participants changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "address"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "Address changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "cap"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "Cap changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "province"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "Province changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "city"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "City changed from #{attr} to #{val}"
            n_changes += 1
          end
        elsif key == "country"
          attr = @event.attributes[key]
          val = value
          if attr != val
            changed_attributes << "Country changed from #{attr} to #{val}"
            n_changes += 1
          end
        else
          attr = @event.attributes[key]
          val = value
          if attr != val
            n_changes += 1
          end
        end
      end
    end

    if !changed_attributes.empty?
      update_message = "Changes: #{changed_attributes.join(", ")}."
    end

    # Update event with new attributes excluding direct photo assignments if necessary
    if @event.update(event_params.except(:photos))
      # Create notification
      if n_changes > 0
        NotificationService.create_notification_update_event(user_organizer: current_user, event: @event, update: update_message)
      end
      # Attach new photos without replacing existing ones
      attach_new_photos if params[:event][:photos].present?

      redirect_to @event, notice: "Event was successfully updated."
    else
      # Manage errors
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    # Generate notifications for the subscribers of the event (and for the owner)
    NotificationService.create_notification_delete_event(
      user_organizer: current_user,
      event: @event,
    )

    @event.destroy
    # Redirect to my_events_path
    redirect_to my_events_path, notice: "Event was successfully destroyed."
  end

  # BULK destroy: multiple events
  def bulk_destroy
    event_ids = params[:event_ids]
    if event_ids.present?
      events = current_user.created_events.where(id: event_ids, user_id: current_user.id)
      events.each do |event|
        NotificationService.create_notification_delete_event(
          user_organizer: current_user,
          event: event,
        )
        event.destroy
      end
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  # delete photo with id
  def delete_photo
    id = params[:photo_id]
    photo = ActiveStorage::Attachment.find_by(id: id)
    if photo.present? && photo.record.user == current_user
      photo.purge
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  # Check if the current user is the owner of the event
  def check_owner
    unless current_user == @event.user
      redirect_to @event, alert: "You are not the organizer of this event."
    end
  end

  # Attach new photo if presents
  def attach_new_photos
    params[:event][:photos].each do |photo|
      unless @event.photos.attach(photo)
        Rails.logger.debug("Failed to attach photo. #{@event.errors[:photos]}")
        flash[:alert] = "Failed to attach photo. #{@event.errors[:photos]}"
        #error cause:
        Rails.logger.debug(@event.errors.full_messages)
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find_by(id: params[:id])
    if @event.nil?
      redirect_to events_path, alert: "Event not found."
    end
  end

  # Only allow a list of trusted parameters through.( the fields that you can modify)
  def event_params
    params.require(:event).permit(:name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province, :city, :country, :description, photos: [])
  end

  # Checks if the current user is logged in and is an organizer
  def check_organizer_role
    unless current_user&.organizer?
      redirect_to root_path, alert: "You must be an organizer to access this section."
    end
  end

  #Format date to iso
  def iso_date(date)
    # Return early if date is nil or not a string or not a date
    return date unless date.is_a?(String)

    if date.include?("-")
      date = date.split("-")
    elsif date.include?("/")
      date = date.split("/")
    else
      return date
    end

    case date.length
    when 3
      return "#{date[2]}-#{date[1]}-#{date[0]}"
    when 2
      return "#{date[1]}-#{date[0]}"
    else
      return date.join("-")
    end
  end

  # Formats the events as JSON
  def format_events_as_json(events, editable)
    events.map do |event|
      {
        #if che current user is an organizer we take the event is, otherwise we need the subscription id
        id: current_user.organizer? ? event.id : current_user.subscriptions.find_by(event_id: event.id).id,
        name: event.name,
        beginning_date: helpers.format_date_with_time(event.beginning_date, event.beginning_time),
        ending_date: helpers.format_date_with_time(event.ending_date, event.ending_time),
        participants: event.subscriptions.count.to_s + "/" + event.max_participants.to_s,
        address: event.address,
        city: event.city,
        cap: event.cap,
        province: event.province,
        country: event.country,
        view_url: event_path(event),
        edit_url: if editable then edit_event_path(event) else "" end,
      }
    end.to_json
  end

  # Formats the subscriptions as JSON
  def format_subscriptions_as_json(subscribtions)
    subscribtions.map do |subscription|
      {
        id: subscription.id,
        user_id: subscription.user_id,
        user_name: subscription.user.name,
        user_surname: subscription.user.surname,
        user_email: subscription.user.email,
        user_address: subscription.user.address,
        user_cap: subscription.user.cap,
        user_province: subscription.user.province,
        user_city: subscription.user.city,
        user_country: subscription.user.country,
        user_date_of_birth: helpers.format_date(subscription.user.date_of_birth),
        subscription_created_at: helpers.format_datetime(subscription.created_at),
      }
    end.to_json
  end
end
