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

        it "is full" do
            event.max_participants = 1
            event.subscribers << build(:user)
            expect(event.full?).to be_truthy
        end

        it "is not full" do
            event.max_participants = 2
            event.subscribers << build(:user)
            expect(event.full?).to be_falsey
        end
    end

end