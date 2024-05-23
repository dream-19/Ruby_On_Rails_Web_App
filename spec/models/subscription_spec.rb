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

    # Generate a random beginning date (it can be in the past)
    def random_date_beginning
      rand(Date.today - 2.year..Date.today + 2.year)
    end

    # Generate a random ending date (it can be in the past and it must be after the beginning)
    def random_date_ending(beginning)
      beginning > Date.today ? rand(beginning..beginning + 2.year) : rand(Date.tomorrow..Date.tomorrow + 2.year)
    end
  
    # Generate a random beginning date and ending date inside the specified range
    def generate_event_dates(start_rand, end_range)
      date1 = rand(start_rand..end_range)
      date2 =  date1 > Date.today ? rand(date1..end_range) : rand(Date.tomorrow..end_range) #ensure ending date is after today
      [date1, date2]
    end
  
    it "case 0 (PBT): new event overlaps with a subscribed event (new event is inside)" do
      user = create(:user_normal)  # Create the user outside the property test

      b_date = random_date_beginning # Randomize the beginning date
      e_date = random_date_ending(b_date) # Randomize the ending date

      overlapping_event = create(:event,  # Ensure you use factory methods correctly
        beginning_date: b_date,
        ending_date: e_date,
      )

      #Subscribe to the event
      create(:subscription, user: user, event: overlapping_event)
    
      # test 100 cases in which the new event I want to subscribe to overlaps with the event I am already subscribed to (the new event is inside the period of the old event)
      100.times do
        new_event_dates = generate_event_dates(b_date, e_date)
        new_event_beginning = new_event_dates.first
        new_event_ending = new_event_dates.last
        new_event = build(:event, beginning_date: new_event_beginning.to_date, ending_date: new_event_ending.to_date)
  
        user.reload  # Reload to ensure the user's subscriptions are up-to-date
        
        new_subscription = build(:subscription, user: user, event: new_event)
  
        # Assertions
        expect(new_subscription.valid?).to be_falsey
        expect(new_subscription.errors[:base]).to include("You are already subscribed to an event that overlaps with this event: #{overlapping_event.name}")
      end
    end

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
  describe "#destroy_with_user" do
    let(:organizer) { create(:user_organizer) }
    let(:non_organizer) { create(:user_normal) }
    let(:event) { create(:event, user: organizer) }
    let(:subscription) { create(:subscription, user: non_organizer, event: event) }

    context "when current user is the organizer" do
      it "calls create_notification_remove_user and destroys the subscription" do
        expect(NotificationService).to receive(:create_notification_remove_user)
            .with(user: subscription.user, event: subscription.event, user_organizer: subscription.event.user)

        subscription.destroy_with_user(organizer)
        # Checking destruction after the expectation ensures sequence is maintained.
        expect(Subscription.exists?(subscription.id)).to be false
      end
    end

    context "when current user is not the organizer" do
      it "calls create_notification_unsubscribe and destroys the subscription" do
        expect(NotificationService).to receive(:create_notification_unsubscribe)
            .with(user: non_organizer, event: event, user_organizer: event.user)

        subscription.destroy_with_user(non_organizer)

        expect(Subscription.exists?(subscription.id)).to be false
      end
    end
  end
end
