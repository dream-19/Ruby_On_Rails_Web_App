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

 
end
