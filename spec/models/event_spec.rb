require "rails_helper"

#Testing per event
RSpec.describe Event, type: :model do
  #Test for the event attribute validations
  describe "Event Attribute Validations" do
    let(:event) { build(:event) }

    it "is valid with valid attributes" do
      expect(event).to be_valid
    end

    it "is invalid without a name" do
      event.name = nil
      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a beginning time" do
      event.beginning_time = nil
      expect(event).not_to be_valid
      expect(event.errors[:beginning_time]).to include("can't be blank")
    end

    it "is invalid without a beginning date" do
      event.beginning_date = nil
      expect(event).not_to be_valid
      expect(event.errors[:beginning_date]).to include("can't be blank")
    end

    it "is invalid without an ending time" do
      event.ending_time = nil
      expect(event).not_to be_valid
      expect(event.errors[:ending_time]).to include("can't be blank")
    end

    it "is invalid without an ending date" do
      event.ending_date = nil
      expect(event).not_to be_valid
      expect(event.errors[:ending_date]).to include("can't be blank")
    end

    it "is invalid without a max participants" do
      event.max_participants = nil
      expect(event).not_to be_valid
      expect(event.errors[:max_participants]).to include("can't be blank")
    end

    it "is invalid without an address" do
      event.address = nil
      expect(event).not_to be_valid
      expect(event.errors[:address]).to include("can't be blank")
    end

    it "is invalid without a cap" do
      event.cap = nil
      expect(event).not_to be_valid
      expect(event.errors[:cap]).to include("can't be blank")
    end

    it "is invalid without a province" do
      event.province = nil
      expect(event).not_to be_valid
      expect(event.errors[:province]).to include("can't be blank")
    end

    it "is invalid without a country" do
      event.country = nil
      expect(event).not_to be_valid
    end

    #check possible nil attributes
    it "is valid without a description" do
      event.description = nil
      expect(event).to be_valid
    end

    # Check attributes lenght
    it "is invalid with a name too long" do
      event.name = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("must be at most 255 characters")
    end

    it "is invalid with an address too long" do
      event.address = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:address]).to include("must be at most 255 characters")
    end

    it "is invalid with a cap too long" do
      event.cap = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:cap]).to include("must be at most 255 characters")
    end

    it "is invalid with a province too long" do
      event.province = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:province]).to include("must be at most 255 characters")
    end

    it "is invalid with a city too long" do
      event.city = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:city]).to include("must be at most 255 characters")
    end

    it "is invalid with a country too long" do
      event.country = "a" * 256
      expect(event).not_to be_valid
      expect(event.errors[:country]).to include("must be at most 255 characters")
    end

    it "is invalid with a description too long" do
      event.description = "a" * 501
      expect(event).not_to be_valid
      expect(event.errors[:description]).to include("must be at most 500 characters")
    end

    # Check attributes numericality
    it "is invalid with a max participants not an integer" do
      event.max_participants = 1.5
      expect(event).not_to be_valid
    end

    it "is invalid with a max participants less than 1" do
      event.max_participants = 0
      expect(event).not_to be_valid
    end

    # Check format date and time (invalid)
    it "is invalid with a beginning date not a date" do
      event.beginning_date = "not a date"
      expect(event).not_to be_valid
    end

    it "is invalid with a beginning time not a time" do
      event.beginning_time = "not a time"
      expect(event).not_to be_valid
    end

    it "is invalid with an ending date not a date" do
      event.ending_date = "not a date"
      expect(event).not_to be_valid
    end

    it "is invalid with an ending time not a time" do
      event.ending_time = "not a time"
      expect(event).not_to be_valid
    end

    it "is invalid with an ending date in the past" do
      event.ending_date = 3.days.ago
      expect(event).not_to be_valid
    end

    it "is invalid with beginning date after ending date" do
      event.beginning_date = 3.days.from_now
      event.ending_date = 2.days.from_now
      expect(event).not_to be_valid
    end

    it "is invalid with beginning date equal to ending date and beginning time < ending time" do
      event.beginning_date = 3.days.from_now
      event.ending_date = 3.days.from_now
      event.beginning_time = "12:12"
      event.ending_time = "12:11"
      expect(event).not_to be_valid
    end

    # Check format date and time (valid)
    it "is valid with a beginning date a date" do
      event.beginning_date = "2021-12-12"
      expect(event).to be_valid
    end

    it "is valid with a beginning time a time" do
      event.beginning_time = "12:12"
      expect(event).to be_valid
    end

    it "is valid with an ending date a date (in the future)" do
      event.beginning_date = 2.days.from_now
      event.ending_date = 3.days.from_now
      expect(event).to be_valid
    end

    it "is valid with an ending time a time" do
      event.ending_time = "12:12"
      expect(event).to be_valid
    end
  end

  # test event methods
  describe "Event Methods" do
    let(:event) { build(:event) }
    let(:event1) { create(:event, beginning_date: 1.day.ago, ending_date: 1.day.from_now, beginning_time: "12:00", ending_time: "13:00") }
    let(:event2) { create(:event, beginning_date: 2.days.from_now, ending_date: 2.days.from_now, beginning_time: "12:00", ending_time: "13:00") }
    let(:event3) { create(:event, beginning_date: 1.day.ago, ending_date: 1.day.from_now, beginning_time: "12:00", ending_time: "18:00") }

    it "is ongoing" do
      event.beginning_date = 1.day.ago
      event.ending_date = 1.day.from_now
      event.beginning_time = "12:00"
      event.ending_time = "13:00"
      expect(event.ongoing?).to be_truthy
    end

    it "is past" do
      event.ending_date = 1.day.ago
      event.ending_time = "12:00"
      expect(event.past?).to be_truthy
    end

    it "is future" do
      event.beginning_date = 1.day.from_now
      event.beginning_time = "12:00"
      expect(event.future?).to be_truthy
    end

    it "checks if the event is at full capacity" do
      event = create(:event, max_participants: 1)
      user = create(:user_normal)
      event.subscribers << user

      expect(event.full?).to be_truthy
    end

    it "is not full" do
      event.max_participants = 2
      event.subscribers << build(:user)
      expect(event.full?).to be_falsey
    end

    it "check method #ongoing" do
      expect(Event.ongoing).to include(event1)
      expect(Event.ongoing).not_to include(event2)
      expect(Event.ongoing).to include(event3)
    end

    it "check method #future" do
      expect(Event.future).not_to include(event1)
      expect(Event.future).to include(event2)
      expect(Event.future).not_to include(event3)
    end

    it "check method #past" do
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
      expect(Event.past).to include(event_past)
    end

    it "checks method #upcoming" do
      expect(Event.upcoming).to include(event1)
      expect(Event.upcoming).to include(event2)
      expect(Event.upcoming).to include(event3)
    end
  end

  describe "scope" do
    it "notfull" do
      user_organizer = create(:user_organizer)
      event_full = create(:event, user: user_organizer, max_participants: 1)
      event_notfull = create(:event, user: user_organizer, max_participants: 2)
      user_normal = create(:user_normal)
      subscription = create(:subscription, user: user_normal, event: event_full)
      subscription2 = create(:subscription, user: user_normal, event: event_notfull)
      expect(Event.notfull).to include(event_notfull)
      expect(Event.notfull).not_to include(event_full)
    end
  end

  # photo validation (active storage)
  describe "photo validations" do
    it "validates with a photo in jpg" do
      event = create(:event)
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.jpg")), filename: "sample_image.jpg", content_type: "image/jpg")
      expect(event).to be_valid
    end

    it "validates with a photo in png" do
      event = create(:event)
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.png")), filename: "sample_image.png", content_type: "image/png")
      expect(event).to be_valid
    end

    it "validates with a photo in gif" do
      event = create(:event)
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.gif")), filename: "sample_image.gif", content_type: "image/gif")
      expect(event).to be_valid
    end

    it "validates with a webp photo" do
      event = create(:event)
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.webp")), filename: "sample_image.webp", content_type: "image/webp")
      expect(event).to be_valid
    end

    it "validate with multiple photos" do
      event = create(:event)
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.jpg")), filename: "sample_image.jpg", content_type: "image/jpg")
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.png")), filename: "sample_image.png", content_type: "image/png")
      expect(event).to be_valid
    end

    it "validates the content type of the photos" do
      event = create(:event)
      # Attaching a valid image
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_image.jpg")), filename: "sample_image.jpg", content_type: "image/jpg")
      # Attaching an invalid file type
      event.photos.attach(io: File.open(Rails.root.join("spec", "fixtures", "files", "sample_document.pdf")), filename: "sample_document.pdf", content_type: "application/pdf")

      event.valid?
      expect(event.errors[:photos]).to include("must be a JPEG/JPG or PNG or GIF")
    end
  end
end
