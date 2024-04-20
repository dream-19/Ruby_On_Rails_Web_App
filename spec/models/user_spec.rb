require "rails_helper"

RSpec.describe User, type: :model do
  # COMMON TESTS for every user type
  describe "User Attribute Validations" do
    include_examples "user attribute validation", :user_normal
    include_examples "user attribute validation", :user_organizer
    include_examples "user attribute validation", :company_organizer
  end

  # TESTS for UserOrganizer, UserNormal
  describe "User Normal require a surname" do
    let(:user) { build(:user_normal) }

    it "is invalid without a surname" do
      user.surname = nil
      expect(user).not_to be_valid
      expect(user.errors[:surname]).to include("can't be blank")
    end
  end

  describe "UserOrganizer require a surname" do
    let(:user) { build(:user_organizer) }

    it "is invalid without a surname" do
      user.surname = nil
      expect(user).not_to be_valid
      expect(user.errors[:surname]).to include("can't be blank")
    end
  end

  describe "UserNormal require a date of birth" do
    let(:user) { build(:user_normal) }

    it "is invalid without a date of birth" do
      user.date_of_birth = nil
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be blank")
    end
  end

  # date of birth can't be in the future
  describe "UserNormal date of birth can't be in the future" do
    let(:user) { build(:user_normal) }

    it "is invalid with a date of birth in the future" do
      user.date_of_birth = 1.day.from_now
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be in the future")
    end
  end

  describe "UserOrganizer date of birth can't be in the future" do
    let (:user) { build(:user_organizer) }

    it "is invalid with a date of birth in the future" do
      user.date_of_birth = 1.day.from_now
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be in the future")
    end
  end

  describe "UserOrganizer require a date of birth" do
    let(:user) { build(:user_organizer) }

    it "is invalid without a date of birth" do
      user.date_of_birth = nil
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be blank")
    end
  end

  describe "UserOrganizer require a phone number" do
    let(:user) { build(:user_organizer) }

    it "is invalid without a phone number" do
      user.phone = nil
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include("can't be blank")
    end
  end

  # TESTS for CompanyOrganizer
  describe "CompanyOrganizer require a phone number" do
    let(:user) { build(:company_organizer) }

    it "is invalid without a phone number" do
      user.phone = nil
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include("can't be blank")
    end
  end

  #company organizer can't have a surname
  describe "CompanyOrganizer can't have a surname" do
    let(:user) { build(:company_organizer) }
    it "is invalid with a surname" do
      user.surname = "surname"
      expect(user).not_to be_valid
      expect(user.errors[:surname]).to include("must be blank")
    end
  end

  # company organizer can't have a date of birth
  describe "CompanyOrganizer can't have a date of birth" do
    let(:user) { build(:company_organizer) }
    it "is invalid with a date of birth" do
      user.date_of_birth = "2021-01-01"
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("must be blank")
    end
  end

  #type tests
  describe "User type tests" do
    let(:user_normal) { create(:user_normal) }
    let(:user_organizer) { create(:user_organizer) }
    let(:company_organizer) { create(:company_organizer) }

    it "is a UserNormal" do
      expect(user_normal.type).to eq("UserNormal")
    end

    it "is a UserOrganizer" do
      expect(user_organizer.type).to eq("UserOrganizer")
    end

    it "is a CompanyOrganizer" do
      expect(company_organizer.type).to eq("CompanyOrganizer")
    end
  end

  describe "#subscribed?" do
    let(:user) { create(:user_normal) }
    let(:event) { create(:event) }

    context "when the user is subscribed to the event" do
      before { create(:subscription, user: user, event: event) }

      it "returns true" do
        expect(user.subscribed?(event)).to be true
      end
    end

    context "when the user is not subscribed to the event" do
      it "returns false" do
        expect(user.subscribed?(event)).to be false
      end
    end
  end

  describe "#count_unread" do
    let(:user) { create(:user_normal) }

    before do
      # create a list of notifications (read and unread)
      create_list(:notification, 5, user: user, read: false)
      create_list(:notification, 3, user: user, read: true)
    end

    it "returns the count of unread notifications" do
      expect(user.count_unread).to eq(5)
    end
  end

  describe "#first_n_unread" do
    let(:user) { create(:user_normal) }

    before do
      create(:notification, user: user, read: false, created_at: 1.day.ago)
      create(:notification, user: user, read: false, created_at: 2.days.ago)
      create(:notification, user: user, read: true, created_at: 3.days.ago)
    end

    it "returns the first n unread notifications in descending order of creation" do
      unread_notifications = user.first_n_unread(2)
      expect(unread_notifications.length).to eq(2)
      expect(unread_notifications.first.created_at).to be > unread_notifications.last.created_at
      expect(unread_notifications.all? { |notification| notification.read == false }).to be true
    end
  end

  # before an user is destroyed send a notification to the events he is subscribed to
  # or to the user that are subscribed to his events
  describe '#notify_event_owners_and_destroy_subscriptions' do
  let(:user) { create(:user_normal) }
  let(:event) { create(:event) }

  #let(:user2) { create(:user_normal) }
  #let(:organizer) { create(:user_organizer) }
  #let(:event2) { create(:event, user: organizer) }

  before do
    create(:subscription, user: user, event: event)
    #create(:subscription, user: user2, event: event2)
  end

  it 'notifies event owners and destroys subscriptions' do
    # expect to receive the method create_notification_unsubscribe_delete
    expect(NotificationService).to receive(:create_notification_unsubscribe_delete).with(user: user, event: event, user_organizer: event.user)
    # expect to receive the method destroy_all (delete all of the subscriptions)
    expect { user.send(:notify_event_owners_and_destroy_subscriptions) }.to change { user.subscriptions.count }.from(1).to(0)
  end

  #it 'notifies the user that the event has been deleted' do
   # expect(NotificationService).to receive(:create_notification_delete_event).with(user_organizer: organizer, event: event2)
    #expect { user2.send(:notify_event_owners_and_destroy_subscriptions) }.to change { user2.subscriptions.count }.from(1).to(0)
  #end
end
end
