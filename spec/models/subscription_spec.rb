require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "validations" do
    it 'user can\'t subscribe to the same event' do
      user = create(:user_normal)
      event = create(:event)
      create(:subscription, user: user, event: event)
      duplicate = build(:subscription, user: user, event: event)

      expect(duplicate.valid?).to be false
      expect(duplicate.errors[:user_id]).to include("You are already subscribed to this event")
    end

    it 'user can\'t subscribe to an event that has already passed' do
      user = create(:user_normal)
      # Create an event that has already passed (skip validation)
      event = Event.new(
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
      event.save(validate: false)
      subscription = build(:subscription, user: user, event: event)

      expect(subscription.valid?).to be false
      expect(subscription.errors[:base]).to include("The event has already passed")
    end

    it 'user can\'t subscribe to an event that is already full' do
      user = create(:user_normal)
      user2 = create(:user_normal)
      event = create(:event, max_participants: 1)
      create(:subscription, user: user2, event: event)
      subscription = build(:subscription, user: user, event: event)

      expect(subscription.valid?).to be false
      expect(subscription.errors[:base]).to include("The event is already full")
    end

    it 'user organizer can\'t subscribe to an event if they are an organizer' do
      user = create(:user_organizer)
      event = create(:event)
      subscription = build(:subscription, user: user, event: event)

      expect(subscription.valid?).to be false
      expect(subscription.errors[:base]).to include("You are an organizer and cannot subscribe to events")
    end

    it 'user company can\'t subscribe to an event if they are an organizer' do
      user = create(:company_organizer)
      event = create(:event)
      subscription = build(:subscription, user: user, event: event)

      expect(subscription.valid?).to be false
      expect(subscription.errors[:base]).to include("You are an organizer and cannot subscribe to events")
    end
  end

  describe "overlaps validation" do
    it "case 1: new event ovelaps with a subscribed event (new event is inside)" do
      user = create(:user_normal)
      overlapping_event = create(:event, beginning_date: 3.days.ago, beginning_time: "10:00", ending_date: 3.days.from_now, ending_time: "12:00")
      create(:subscription, user: user, event: overlapping_event)

      user.reload #reload the user to get the subscribed events

      #the next one will not be valid
      new_event = build(:event, beginning_date: 2.days.ago, beginning_time: "11:00", ending_date: 2.days.from_now, ending_time: "13:00")
      new_subscription = build(:subscription, user: user, event: new_event)

      expect(new_subscription.valid?).to be false
      expect(new_subscription.errors[:base]).to include("You are already subscribed to an event that overlaps with this event: #{overlapping_event.name}")
    end

    it "case 2: new event overlaps with a subscribed event (beginning inside another event)" do
      user = create(:user_normal)
      overlapping_event = create(:event, beginning_date: 3.days.ago, beginning_time: "10:00", ending_date: 3.days.from_now, ending_time: "12:00")
      create(:subscription, user: user, event: overlapping_event)

      user.reload

      #the next one will not be valid
      new_event = build(:event, beginning_date: 2.days.ago, beginning_time: "11:00", ending_date: 4.days.from_now, ending_time: "13:00")
      new_subscription = build(:subscription, user: user, event: new_event)

      expect(new_subscription.valid?).to be false
      expect(new_subscription.errors[:base]).to include("You are already subscribed to an event that overlaps with this event: #{overlapping_event.name}")
    end

    it "case 3: new event overlaps with a subscribed event (ending date inside another event)" do
      user = create(:user_normal)
      overlapping_event = create(:event, beginning_date: 3.days.ago, beginning_time: "10:00", ending_date: 3.days.from_now, ending_time: "12:00")
      create(:subscription, user: user, event: overlapping_event)

      user.reload

      #the next one will not be valid
      new_event = build(:event, beginning_date: 4.days.ago, beginning_time: "11:00", ending_date: 2.days.from_now, ending_time: "11:59")
      new_subscription = build(:subscription, user: user, event: new_event)

      expect(new_subscription.valid?).to be false
      expect(new_subscription.errors[:base]).to include("You are already subscribed to an event that overlaps with this event: #{overlapping_event.name}")
    end

    it "case 4: new event overlaps with a subscribed event (old event is inside) " do
      user = create(:user_normal)
      overlapping_event = create(:event, beginning_date: 2.days.ago, beginning_time: "10:00", ending_date: 2.days.from_now, ending_time: "12:00")
      create(:subscription, user: user, event: overlapping_event)

      user.reload

      #the next one will not be valid
      new_event = build(:event, beginning_date: 3.days.ago, beginning_time: "11:00", ending_date: 3.days.from_now, ending_time: "13:00")
      new_subscription = build(:subscription, user: user, event: new_event)

      expect(new_subscription.valid?).to be false
      expect(new_subscription.errors[:base]).to include("You are already subscribed to an event that overlaps with this event: #{overlapping_event.name}")
    end
  end

  #test the notifications
  describe "notifications" do
    it "creates notifications upon saving" do
      user = create(:user_normal)
      event = create(:event)
      subscription = build(:subscription, user: user, event: event)

      expect(NotificationService).to receive(:create_notification_subscribe).with(user: user, event: event, user_organizer: event.user)
      subscription.save
    end

    it "create notifications upon saving if the event is at full capacity" do
      user = create(:user_normal)
      event = create(:event, max_participants: 1)
      subscription = build(:subscription, user: user, event: event)

      expect(NotificationService).to receive(:create_notification_full_capacity).with(user_organizer: event.user, event: event)
      subscription.save
    end

  end

  # check method destroy with user
    # if the current user is the organizer, it should call create_notification_remove_user and destroy the subscription
    # if the current user is not the organizer, it should call create_notification_unsubscribe and destroy the subscription
    # authorization is checked in the controller, before calling the method
  describe '#destroy_with_user' do
    let(:organizer) { create(:user_organizer) }
    let(:non_organizer) { create(:user_normal) }
    let(:event) { create(:event, user: organizer) }
    let(:subscription) { create(:subscription, user: non_organizer, event: event) }

    context 'when current user is the organizer' do
        it "calls create_notification_remove_user and destroys the subscription" do
            expect(NotificationService).to receive(:create_notification_remove_user)
              .with(user: subscription.user, event: subscription.event, user_organizer: subscription.event.user)
          
            subscription.destroy_with_user(organizer)
            # Checking destruction after the expectation ensures sequence is maintained.
            expect(Subscription.exists?(subscription.id)).to be false
          end
          
    end

    context 'when current user is not the organizer' do
      it 'calls create_notification_unsubscribe and destroys the subscription' do
        expect(NotificationService).to receive(:create_notification_unsubscribe)
          .with(user: non_organizer, event: event, user_organizer: event.user)
        
        subscription.destroy_with_user(non_organizer) 

        expect(Subscription.exists?(subscription.id)).to be false
      end
    end
  end
  
end
