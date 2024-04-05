require "rails_helper"

RSpec.describe User, type: :model do

  it "user_normal is valid with valid attributes" do
    user = build(:user_normal)
    expect(user).to be_valid
  end

  it "user_organizer is valid with valid attributes" do
    user = build(:user_organizer)
    expect(user).to be_valid
  end

  it "company_organizer is valid with valid attributes" do
    user = build(:company_organizer)
    expect(user).to be_valid
  end

  # email validation for user_normal, user_organizer, and company_organizer
  describe "Email Validations" do
    include_examples "email validation", :user_normal
    include_examples "email validation", :user_organizer
    include_examples "email validation", :company_organizer
  end

  
end
