require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  let(:organizer) { create(:user_organizer) }
  let(:user) { create(:user_normal) }
  let(:event) { create(:event, user: organizer, beginning_date: 1.day.from_now, ending_date: 2.day.from_now) }
  let(:subscription) { create(:subscription, user: user, event: event) }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "when subscribing to an event" do
      it "creates a new subscription" do
        expect {
          post :create, params: { event_id: event.id }
        }.to change(Subscription, :count).by(1)
        expect(response).to redirect_to(event_path(event))
      end

      it "handles failure to save subscription" do
        allow_any_instance_of(Subscription).to receive(:save).and_return(false)
        post :create, params: { event_id: event.id }
        expect(response).to redirect_to(event_path(event))
      end
    end
  end

  describe "DELETE #destroy" do
    it "unsubscribes from an event" do
      subscription  # this triggers the creation of the subscription
      expect {
        delete :destroy, params: { id: subscription.id, event_id: event.id }
      
      }.to change(Subscription, :count).by(-1)
      expect(flash[:notice]).to be_present
      expect(response).to redirect_to(events_path)  # fallback_location
    end

    it "handles unsubscription from a past event" do
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
        user: create(:user_organizer),
      )
      event_past.save(validate: false)
      subscription_past = Subscription.new(user: user, event: event_past)
      subscription_past.save(validate: false)
      delete :destroy, params: { id: subscription_past.id, event_id: event_past.id }
      expect(flash[:alert]).to eq("You cannot unsubscribe from a past event.")
      expect(response).to redirect_to(events_path)
    end
  end

  describe "POST #bulk_destroy_sub" do
    it "unsubscribes multiple subscriptions" do
      subscriptions = create_list(:subscription, 1, user: user)
      post :bulk_destroy_sub, params: { sub_ids: subscriptions.map(&:id) }, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["success"]).to be true
    end

    it "handles unauthorized attempts to unsubscribe" do
      another_user = create(:user_normal)
      another_subscription = create(:subscription, user: another_user, event: event)
      post :bulk_destroy_sub, params: { sub_ids: [another_subscription.id] }, format: :json
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["message"]).to include("You are not authorized")
    end

    it "fails if a subscription is not found" do
      post :bulk_destroy_sub, params: { sub_ids: [999] }, format: :json
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["message"]).to include("Subscription not found")
    end
  end
end
