class EventsController < ApplicationController
  #check Authentication
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :check_organizer_role, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
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

      # Check if search is present
      if params[:search].present? and params[:search_by].present?
        # special cases (organizer, date)
        if params[:search_by] == 'organizer' # organizer can be name + surname
          #TODO
          @events = @events.joins(:user).where('users.name LIKE ? AND users.surname LIKE ?', '%' + params[:search] + '%', '%' + params[:search] + '%')
        elsif params[:search_by] == ('beginning_date' || 'ending_date')
          #TODO
          date =params[:search]
          @events = @events.where(params[:search_by] + ' LIKE ?', date)
          
        else
          @events = @events.where(params[:search_by] + ' LIKE ?', '%' + params[:search] + '%')
        end
      end
    else 
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

    # Only the organizer can modify the event
    unless current_user == @event.user
      redirect_to @event, alert: 'You are not the organizer of this event.'
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
    # Ensure only the organizer can update the event
    unless current_user == @event.user
      redirect_to @event, alert: 'You are not authorized to update this event.'
      return
    end

    # Check if the number of participants hasn't been lowered too much
    if event_params[:max_participants].to_i <  @event.subscriptions.count
      redirect_to edit_event_path(@event), alert: 'The number of participants cannot be lowered below the current number of attendees: ' + @event.subscriptions.count.to_s
      return
    end
    @event.subscriptions.count
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render my_events_path
    end
  end

  # DELETE /events/1
  def destroy
    # Only the organizer can destroy the event
    unless current_user == @event.user
      redirect_to @event, alert: 'You are not authorized to destroy this event.'
      return
    end

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

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by(id: params[:id])
      if @event.nil?
        redirect_to events_path, alert: 'Event not found.'
      end
    end

    # Only allow a list of trusted parameters through.( the fields that you can modify)
    def event_params
      params.require(:event).permit(:name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province, :city, :country, :description)
    end

  
    # Checks if the current user is logged in and is an organizer
    def check_organizer_role
      unless current_user&.user_organizer?
        redirect_to root_path, alert: 'You must be an organizer to access this section.'
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
