require "rails_helper"

RSpec.describe EventsController, type: :controller do
  let(:user_normal) { create(:user_normal) }
  let(:organizer) { create(:user_organizer, name: "bbb") }
  let(:organizer2) { create(:user_organizer, name: "aaa") }
  let(:event2) { create(:event, name: "bbb", user: organizer2, beginning_date: 5.days.from_now, ending_date: 6.days.from_now) }
  let(:event) { create(:event, name: "aaa", user: organizer, beginning_date: 2.days.from_now, ending_date: 3.days.from_now) }

  let(:ongoing_event) { create(:event, beginning_date: 1.day.ago, ending_date: 1.day.from_now) }
  let(:not_full_event) { create(:event, max_participants: 10, beginning_date: 3.day.ago, ending_date: 2.day.from_now) }

  before do
    sign_in user_normal
    allow(controller).to receive(:format_subscriptions_as_json).and_call_original #stubbing the method
  end

  def format_subscriptions_as_json(subscriptions)
    subscriptions.map do |subscription|
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
        user_date_of_birth: format_date(subscription.user.date_of_birth),
        subscription_created_at: format_datetime(subscription.created_at),
      }
    end.to_json
  end

  describe "GET #index" do
  context "with search_by parameter" do
    context "when searching by organizer" do
      it "returns events by organizer name and surname" do
        get :index, params: { search_by: "organizer", search: "aaa" }
        expect(assigns(:events)).to match_array([event])
      end
    end

    context "when searching by beginning_date" do
      it "returns events by beginning date" do
        get :index, params: { search_by: "beginning_date", search: event.beginning_date.to_s }
        expect(assigns(:events)).to eq([event])
      end
    end

    context "when searching by ending_date" do
      it "returns events by ending date" do
        get :index, params: { search_by: "ending_date", search: event2.ending_date.to_s }
        expect(assigns(:events)).to eq([event2])
      end
    end

    context "when searching by date interval" do
      it "returns events within the date interval" do
        get :index, params: { search_by: "interval", from_date: 3.days.ago.to_s, to_date: 4.days.from_now.to_s }
        expect(assigns(:events)).to match_array([event])
      end

      it "returns events starting from a specific date" do
        get :index, params: { search_by: "interval", from_date: 3.days.from_now.to_s }
        expect(assigns(:events)).to match_array([event2])
      end

      it "returns events ending until a specific date" do
        get :index, params: { search_by: "interval", to_date: 4.days.from_now.to_s }
        expect(assigns(:events)).to match_array([event])
      end
    end

    context "when searching by other fields" do
      it "returns events matching the search term" do
        event4 = create(:event, user: organizer, address: "Test Address")
        get :index, params: { search_by: "address", search: "Test Address" }
        expect(assigns(:events)).to eq([event4])
      end
    end
  end

    context "with my_events parameter" do
      context "when the user is signed in" do
        context "when the user is an organizer" do
          before do
            sign_in organizer
            event
            event2
          end

          it "returns created events for the organizer" do
            get :index, params: { my_events: true }
            expect(assigns(:events)).to eq([event, event2])
          end
          it "returns upcoming created events for the organizer" do
            allow(Event).to receive(:upcoming).and_return(Event.where(id: [event.id, event2.id]))
            get :index, params: { my_events: true }
            expect(assigns(:events)).to match_array([event, event2])
          end
        end

        context "when the user is not an organizer" do
          let(:event3) { create(:event) }
          before do
            create(:subscription, user: user_normal, event: event3)
            sign_in user_normal
          end

          it "returns subscribed events for the user" do
            get :index, params: { my_events: true }
            expect(assigns(:events)).to eq([event3])
          end
          it "returns upcoming subscribed events for the user" do
            allow(Event).to receive(:upcoming).and_return(Event.where(id: [event3.id]))
            get :index, params: { my_events: true }
            expect(assigns(:events)).to match_array([event3])
          end
        end
      end

      context "with on_going parameter" do
        before do
          allow(Event).to receive(:ongoing).and_return([ongoing_event])
        end

        it "returns only ongoing events" do
          get :index, params: { on_going: true }
          expect(assigns(:events)).to eq([ongoing_event])
        end
      end

      context "with not_full parameter" do
        before do
          allow(Event).to receive(:notfull).and_return([not_full_event])
        end

        it "returns only not full events" do
          get :index, params: { not_full: true }
          expect(assigns(:events)).to eq([not_full_event])
        end
      end

      context "with both on_going and not_full parameters" do
        before do
          allow(Event).to receive(:ongoing).and_return([ongoing_event])
          allow(Event).to receive(:notfull).and_return([not_full_event])
        end

        it "returns only events that are ongoing and not full" do
          get :index, params: { on_going: true, not_full: true }
          expect(assigns(:events)).to eq([not_full_event, ongoing_event])
        end
      end

      context "when the user is not signed in" do
        before do
          sign_out user_normal
        end

        it "returns no events" do
          get :index, params: { my_events: true }
          expect(assigns(:events)).to be_empty
        end
      end
    end

    context "without any parameters" do
      it "returns upcoming events ordered by beginning_date and beginning_time" do
        get :index
        expect(assigns(:events)).to eq([event, event2])
      end
    end

    context "with order_by parameter" do
      it "orders events by organizer name" do
        get :index, params: { order_by: "organizer", direction: "asc" }
        expect(assigns(:events)).to eq([event2, event])
      end

      it "orders events by participants count" do
        get :index, params: { order_by: "participants", direction: "desc" }
        expect(assigns(:events)).to eq([event, event2])
      end

      it "orders events by beginning_date" do
        get :index, params: { order_by: "beginning_date", direction: "asc" }
        expect(assigns(:events)).to eq([event, event2])
      end

      it "orders events by default" do
        get :index, params: { order_by: "name", direction: "asc" }
        expect(assigns(:events)).to eq([event, event2])
      end
    end

    context "with my_events parameter" do
      before do
        sign_in organizer
      end

      it "returns created events for organizer" do
        get :index, params: { my_events: true }
        expect(assigns(:events)).to eq([event, event2])
      end

      it "returns subscribed events for normal user" do
        create(:subscription, user: user_normal, event: event)
        get :index, params: { my_events: true }
        expect(assigns(:events)).to eq([event])
      end
    end

    context "with on_going parameter" do
      it "returns ongoing events" do
        allow(Event).to receive(:ongoing).and_return([event])
        get :index, params: { on_going: true }
        expect(assigns(:events)).to eq([event])
      end
    end

    context "with not_full parameter" do
      it "returns not full events" do
        allow(Event).to receive(:notfull).and_return([event])
        get :index, params: { not_full: true }
        expect(assigns(:events)).to eq([event])
      end
    end

   

    context "when there is an SQL error" do
      before do
        allow(Event).to receive(:upcoming).and_raise(ActiveRecord::StatementInvalid.new("Simulated SQL error"))
      end

      it "logs the error and sets a flash message" do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch events: Simulated SQL error/)
        get :index
        expect(flash[:error]).to eq("There was a problem fetching the events.")
        expect(assigns(:events)).to eq(Event.order(beginning_date: :asc).page(nil).per(18))
      end
    end
  end

  describe "GET #show" do
    context "when the event exists" do
      it "returns a success response" do
        get :show, params: { id: event.id }
        expect(response).to be_successful
      end

      it "assigns the requested event to @event" do
        get :show, params: { id: event.id }
        expect(assigns(:event)).to eq(event)
      end

      context "when the current user is the organizer" do
        before do
          sign_in organizer
        end

        it "assigns the event subscriptions to @subscriptions" do
          get :show, params: { id: event.id }
          expect(assigns(:subscriptions)).to eq(event.subscriptions)
        end

        it "assigns the formatted subscriptions to @subscriptions_json" do
          get :show, params: { id: event.id }
          formatted_json = format_subscriptions_as_json(event.subscriptions)
          allow(controller).to receive(:format_subscriptions_as_json).with(event.subscriptions).and_return(formatted_json)
        end
      end

      context "when the current user is not the organizer" do
        it "does not assign subscriptions to @subscriptions" do
          get :show, params: { id: event.id }
          expect(assigns(:subscriptions)).to be_nil
        end

        it "does not assign formatted subscriptions to @subscriptions_json" do
          get :show, params: { id: event.id }
          expect(assigns(:subscriptions_json)).to be_nil
        end
      end
    end

    context "when the event is nil" do
      it "redirects to the events list with an alert" do
        get :show, params: { id: "notanid" }
        expect(response).to redirect_to(events_path)
        expect(flash[:alert]).to eq("Event not found.")
      end
    end
  end

  describe "GET #new" do
    before do
      sign_in organizer
    end

    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new event to @event" do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end

    context "when the current user is not an organizer" do
      it "redirects to the root path with an alert" do
        sign_in user_normal
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You must be an organizer to access this section.")
      end
    end
  end

  describe "GET #edit" do
    before do
      sign_in organizer
    end

    it "returns a success response" do
      get :edit, params: { id: event.id }
      expect(response).to be_successful
    end

    it "assigns the requested event to @event" do
      get :edit, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end

    it "fails if I try to edit a past event" do
      event_past = Event.new(
        name: "Event",
        max_participants: 10,
        beginning_date: 2.days.ago,
        ending_date: 1.day.ago,
        beginning_time: "10:00",
        ending_time: "12:00",
        address: "Address",
        cap: "City",
        country: "Country",
        province: "Province",
        city: "City",
        user: organizer,
      )
      event_past.save(validate: false)
      get :edit, params: { id: event_past.id }
      expect(response).to redirect_to(event_past)
      expect(flash[:alert]).to eq("You cannot edit an event that has already ended.")
    end
  end

  describe "POST #create" do
    before do
      sign_in organizer
    end

    context "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, params: { event: attributes_for(:event) }
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: { event: attributes_for(:event) }
        expect(response).to redirect_to(Event.last)
      end
    end

    context "with invalid params" do
      it "does not create a new Event" do
        expect {
          post :create, params: { event: attributes_for(:event, name: nil) }
        }.to change(Event, :count).by(0)
      end
    end
  end

  describe "PUT #update" do
    before do
      sign_in organizer
    end

    context "with valid params" do
      let(:new_attributes) {
        {
          name: "New Event Name",
          max_participants: 20,
          beginning_date: Date.today + 1,
          ending_date: Date.today + 2,
          beginning_time: "09:00",
          ending_time: "11:00",
          address: "New Address",
          cap: "New City",
          country: "New Country",
          province: "New Province",
          city: "New City",
          description: "New Description",
        }
      }

      it "updates the requested event with the new attributes" do
        put :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.name).to eq("New Event Name")
      end

      it "redirects to the event" do
        put :update, params: { id: event.id, event: new_attributes }
        expect(response).to redirect_to(event)
      end
    end

    context "with invalid params" do
      it "does not update the event" do
        put :update, params: { id: event.id, event: { name: nil } }
        event.reload
        expect(event.name).to_not be_nil
      end

      it "renders the edit template" do
        put :update, params: { id: event.id, event: { name: nil } }
        expect(response).to render_template(:edit)
      end
    end

    context "when the event has already ended" do
      let(:past_event) do
        event = create(:event, user: organizer)
        event.ending_date = Date.yesterday
        event.save(validate: false)
        event
      end

      it "redirects to the event with an alert" do
        put :update, params: { id: past_event.id, event: { name: "Updated Event" } }
        expect(response).to redirect_to(past_event)
        expect(flash[:alert]).to eq("You cannot edit an event that has already ended.")
      end
    end

    context "when lowering max participants below current subscriptions" do
      let!(:subscription) { create(:subscription, event: event, user: user_normal) }

      it "redirects to the edit event path with an alert" do
        put :update, params: { id: event.id, event: { max_participants: 0 } }
        expect(response).to redirect_to(edit_event_path(event))
        expect(flash[:alert]).to eq("The number of participants cannot be lowered below the current number of attendees: 1")
      end
    end
  end
  describe "DELETE #destroy" do
    before do
      sign_in organizer
      event
    end

    it "destroys the requested event" do
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      delete :destroy, params: { id: event.id }
      expect(response).to redirect_to(my_events_path)
    end

    context "when the current user is not the organizer" do
      it "does not delete the event and redirects with an alert" do
        delete :destroy, params: { id: event2.id }
        expect(response).to redirect_to(event2)
        expect(flash[:alert]).to eq("You are not the organizer of this event.")
      end
    end
  end

  describe "GET #my_events_user" do
    it "returns a success response" do
      sign_in user_normal
      get :my_events_user
      expect(response).to be_successful
    end
  end

  describe "GET #my_events" do
    before do
      sign_in organizer
    end

    it "returns a success response" do
      get :my_events
      expect(response).to be_successful
    end
  end

  describe "GET #data" do
    before do
      sign_in organizer
    end

    it "returns a success response for current events" do
      get :data, params: { event_type: "current" }
      expect(response).to be_successful
    end

    it "returns a success response for future events" do
      get :data, params: { event_type: "future" }
      expect(response).to be_successful
    end

    it "returns a success response for past events" do
      get :data, params: { event_type: "past" }
      expect(response).to be_successful
    end

    it "returns an empty array for a different attribute" do
      get :data, params: { event_type: "nonexistent" }
      expect(response.body).to eq("[]")
    end
  end

  describe "POST #bulk_destroy" do
    before do
      sign_in organizer
    end

    it "destroys the requested events" do
      events = create_list(:event, 3, user: organizer)
      event_ids = events.map(&:id)
      expect {
        post :bulk_destroy, params: { event_ids: event_ids }
      }.to change(Event, :count).by(-3)
    end

    it "fails if events id is not present" do
      post :bulk_destroy, params: { event_ids: [] }
      # render json: { success: false }, status: :unprocessable_entity
      expect(response.body).to eq("{\"success\":false}")
    end
  end

  describe "DELETE #delete_photo" do
    before do
      sign_in organizer
      @photo = event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.jpg")), filename: "sample_image.jpg", content_type: "image/jpg").first
    end

    it "deletes the photo" do
      expect {
        delete :delete_photo, params: { photo_id: @photo.id }
      }.to change(ActiveStorage::Attachment, :count).by(-1)
    end

    context "when the photo does not exist" do
      it "returns an unprocessable entity response" do
        delete :delete_photo, params: { photo_id: "nonexistent_id" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  describe "#format_subscriptions_as_json" do
    let(:subscription) { create(:subscription, user: user_normal, event: event) }

    it "formats subscriptions as JSON" do
      expected_json = [
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
          user_date_of_birth: format_date(subscription.user.date_of_birth),
          subscription_created_at: format_datetime(subscription.created_at),
        },
      ].to_json

      json_result = controller.send(:format_subscriptions_as_json, [subscription])
      expect(json_result).to eq(expected_json)
    end

    describe "#format_events_as_json" do
      before do
        allow(controller).to receive(:current_user).and_return(organizer)
      end
      it "formats events as JSON for organizer" do
        expected_json = [
          {
            id: event.id,
            name: event.name,
            beginning_date: format_date_with_time(event.beginning_date, event.beginning_time),
            ending_date: format_date_with_time(event.ending_date, event.ending_time),
            participants: "#{event.subscriptions.count}/#{event.max_participants}",
            address: event.address,
            city: event.city,
            cap: event.cap,
            province: event.province,
            country: event.country,
            view_url: event_path(event),
            edit_url: edit_event_path(event),
          },
        ].to_json

        json_result = controller.send(:format_events_as_json, [event], true)
        expect(json_result).to eq(expected_json)
      end
    end
  end

  describe "POST #update with photos" do
    before do
      sign_in organizer
    end
    let(:photo) { fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "sample_image.png"), "image/png") }

    context "when photos are attached successfully" do
      it "attaches photos to the event" do
        patch :update, params: { id: event.id, event: { photos: [photo] } }
        event.reload
        expect(event.photos).to be_attached
      end
    end

    context "when photo attachment fails" do
      before do
        allow_any_instance_of(ActiveStorage::Attached::Many).to receive(:attach).and_return(false)
      end

      it "sets a flash alert message" do
        patch :update, params: { id: event.id, event: { photos: [photo] } }
        expect(flash[:alert]).to eq("Failed to attach photo. []")
      end

      it "logs an error message" do
        expect(Rails.logger).to receive(:debug).at_least(:twice)
        patch :update, params: { id: event.id, event: { photos: [photo] } }
      end
    end
  end
end
