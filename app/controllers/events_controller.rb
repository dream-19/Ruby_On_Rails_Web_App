class EventsController < ApplicationController
  #check Authentication
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :check_organizer_role, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @events = Event.upcoming
    
    #.order(params[:sort_by])
  end

  def my_events
    @events = current_user.events # Assumendo che tu abbia una relazione `has_many :events` in User
    render :my_events
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
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
    Rails.logger.debug("CARLA")
    # Only the organizer can destroy the event
    unless current_user == @event.user
      redirect_to @event, alert: 'You are not authorized to destroy this event.'
      return
    end

    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
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
    
end
