class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  #check Authentication
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :check_organizer_role, only: [:new, :create, :edit, :update, :destroy, :my_events]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @events = Event.all
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
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
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
      params.require(:event).permit(:name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province, :city, :country)
    end

  
    # Checks if the current user is logged in and is an organizer
    def check_organizer_role
      Rails.logger.info "CARLA WHAT ARE U"
      unless current_user&.user_organizer?
        Rails.logger.info "CARLAUser #{current_user&.id} is not an organizer"
        redirect_to root_path, alert: 'You must be an organizer to access this section.'
      end
    end
    
end
