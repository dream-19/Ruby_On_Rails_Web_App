require "rails_helper"

RSpec.describe Notification, type: :model do

  #check validation
  describe "validations" do
    #must be valid with all attributes present
    it "is valid with all attributes present" do
      notification = build(:notification)
      expect(notification.valid?).to be true
    end

    it "validates presence of message" do
      notification = Notification.new(notification_type: "event_update", read: false)
      expect(notification.valid?).to be false
      expect(notification.errors[:message]).to include("can't be blank")
    end

    it "validates presence of notification_type" do
      notification = Notification.new(message: "Event canceled", read: false)
      expect(notification.valid?).to be false
      expect(notification.errors[:notification_type]).to include("can't be blank")
    end

    #assure the notification is valid with and without an event associated
    it "is valid with an event associated" do
      user_organizer = create(:user_organizer)
      event = create(:event, user: user_organizer)
      notification = build(:notification, event: event, user: user_organizer)
      expect(notification.valid?).to be true
    end

    it "is valid without an event associated" do
      notification = build(:notification, event: nil)
      expect(notification.valid?).to be true
    end
  end

  #check class methods
  describe "class methods" do
    before do
        user = create(:user_normal)
      create_list(:notification, 3, read: true, user: user)
      create_list(:notification, 2, read: false, user: user)
    end

    describe ".read" do
      it "returns the count of read notifications" do
        expect(Notification.read).to eq(3)
      end
    end

    describe ".unread" do
      it "returns the count of unread notifications" do
        expect(Notification.unread).to eq(2)
      end
    end
  end
end
