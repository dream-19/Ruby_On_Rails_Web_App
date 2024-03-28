class EventsController < ApplicationController
  #check Authentication
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  # Check if the user in an organizer to access this functions
  before_action :check_organizer_role, only: [:new, :create, :edit, :update, :destroy, :my_events, :bulk_destroy, :delete_photo, :data]
  before_action :check_owner, only: [:edit, :update, :destroy]

  # GET /events
  def index
    begin
    if params[:order_by].present? 
      direction = params[:order_by].split('-')[1] # this can be 'asc' or 'desc'
      params[:order_by] = params[:order_by].split('-')[0]

      if params[:order_by] == 'organizer'
        @events = Event.upcoming.joins(:user).order('users.name ' +  direction)
      elsif params[:order_by] == 'participants'
        @events = direction == 'asc' ? Event.upcoming.left_joins(:subscriptions).group('events.id').order('COUNT(subscriptions.id) ASC' ) : Event.upcoming.left_joins(:subscriptions).group('events.id').order('COUNT(subscriptions.id) DESC' )
      else
        #Normal case with order
      @events =  Event.upcoming.order(params[:order_by] + ' ' + direction) 
    
      end

      # Check if search is present (normal search or interval search)
      if params[:search_by].present? and (params[:search].present? || params[:from_date].present? || params[:to_date].present? ) 
        # special cases (organizer, date)
        if params[:search_by] == 'organizer' # organizer can be name + surname
          @events = @events.joins(:user).where('CONCAT(users.name,\' \',users.surname) LIKE ?', '%' + params[:search] + '%')
         elsif params[:search_by] == ('beginning_date' || 'ending_date')
          #TODO
          date = iso_date(params[:search])
          @events = @events.where(params[:search_by] + ' LIKE ?','%' + date + '%')
          
         elsif params[:search_by] == 'interval'
          from_date = params[:from_date]
          to_date = params[:to_date]
          
          if from_date.present? && to_date.present?
            @events = @events.where('beginning_date >= ? AND ending_date <= ?', from_date, to_date)
          elsif from_date.present?
            @events = @events.where('beginning_date >= ?', from_date)
          else 
            @events = @events.where('ending_date <= ?', to_date)
          end

        else
          @events = @events.where(params[:search_by] + ' LIKE ?', '%' + params[:search] + '%')
        end
      end
    else 
      @events = Event.upcoming.order(beginning_date: :asc)
    end
  
  
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error "Failed to fetch events: #{e.message}"
    flash[:error] = "There was a problem fetching the events."
    
    # Redirect or set @events to a safe default
    @events = Event.upcoming.order(beginning_date: :asc)
  end

  respond_to do |format|
    format.html # For regular requests
    format.js { render partial: 'events_list', locals: { events: @events }, layout: false } # For AJAX requests
  end

  
    
  end

  def my_events
    @current_events = current_user.events.upcoming
    @current_events_json = format_events_as_json(@current_events, true) #true for edit
    
    @past_events = current_user.events.past
    @past_events_json = format_events_as_json(@past_events, false) #false for no edit
    
    render :my_events
  end

  # GET /events/data
  def data
    case params[:event_type]
    when 'current'
      @current_events = current_user.events.upcoming.order(beginning_date: :asc)
      events_data = format_events_as_json(@current_events,true)
    when 'past'
      @past_events = current_user.events.past.order(ending_date: :desc)
      events_data = format_events_as_json(@past_events, false)
    else
      events_data = [].to_json
    end
    render json: events_data
  end

  # GET /events/1
  def show
    @event = Event.find_by(id: params[:id])
    if @event.nil?
      redirect_to events_path, alert: 'Event not found.'
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    # Check if the event has already ended
    if @event.ending_date < Date.today
      redirect_to @event, alert: 'You cannot edit an event that has already ended.'
    end

  end

  # POST /events
  def create
    @event = current_user.events.build(event_params)
    if @event.save
      # Reindirizzamento in caso di successo
      redirect_to @event, notice: 'Event was successfully created.'
      
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
      redirect_to @event, alert: 'You cannot edit an event that has already ended.'
      return
    end

    # Check if the number of participants hasn't been lowered too much
    if event_params[:max_participants].to_i < @event.subscriptions.count
      redirect_to edit_event_path(@event), alert: 'The number of participants cannot be lowered below the current number of attendees: ' + @event.subscriptions.count.to_s
      return
    end

      # Update event with new attributes excluding direct photo assignments if necessary
    if @event.update(event_params.except(:photos))
        # Attach new photos without replacing existing ones
        attach_new_photos if params[:event][:photos].present?
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      # Manage errors
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    # Redirect to my_events_path
    redirect_to my_events_path, notice: 'Event was successfully destroyed.'
  end

  # BULK destroy: multiple events
  def bulk_destroy
    event_ids = params[:event_ids]
    if event_ids.present?
      current_user.events.where(id: event_ids, user_id: current_user.id).destroy_all
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
      redirect_to @event, alert: 'You are not the organizer of this event.'
    end
  end

  # Attach new photo if presents
  def attach_new_photos
      params[:event][:photos].each do |photo|
        @event.photos.attach(photo)
    end
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by(id: params[:id])
      if @event.nil?
        redirect_to events_path, alert: 'Event not found.'
      end
    end

    # Only allow a list of trusted parameters through.( the fields that you can modify)
    def event_params
      params.require(:event).permit(:name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province, :city, :country, :description, photos: [])
    end

  
    # Checks if the current user is logged in and is an organizer
    def check_organizer_role
      unless current_user&.user_organizer?
        redirect_to root_path, alert: 'You must be an organizer to access this section.'
      end
    end

    #Format date to iso
    def iso_date(date)
      # Return early if date is nil or not a string or not a date
      return date unless date.is_a?(String)
      
      Rails.logger.debug("date: #{date}")
      
      if date.include?('-')
        date = date.split('-')
      elsif date.include?('/')
        date = date.split('/')
      else
        Rails.logger.debug("primo else: #{date}")
        return date
      end
    
      case date.length
      when 3
        Rails.logger.debug("secondo if: #{date[2]}-#{date[1]}-#{date[0]}")
        return "#{date[2]}-#{date[1]}-#{date[0]}"
      when 2
        Rails.logger.debug("secondo else: #{date[1]}-#{date[0]}")
        return "#{date[1]}-#{date[0]}"
      else
        Rails.logger.debug("terzo else: #{date.join('-')}")
        return date.join('-')
      end
    end
    

    # Formats the events as JSON
    def format_events_as_json(events, editable)
      events.map do |event|
        {
          id: event.id,
          name: event.name,
          beginning_date: helpers.format_date(event.beginning_date),
          beginning_time: helpers.format_time(event.beginning_time),
          ending_date: helpers.format_date(event.ending_date),
          ending_time: helpers.format_time(event.ending_time),
          participants: event.subscriptions.count,
          max_participants: event.max_participants,
          address: event.address,
          city: event.city,
          cap: event.cap,
          province: event.province,
          country: event.country,
          view_url: event_path(event),
          edit_url: if editable then edit_event_path(event) else '' end,
        }
      end.to_json
    end
    
end
