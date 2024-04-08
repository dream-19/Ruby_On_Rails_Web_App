# spec/support/shared_examples/user_email_validation.rb
RSpec.shared_examples "user attribute validation" do |user_factory|
  let(:user) { build(user_factory) }

  # check if user is valid with valid attributes
  it "#{user_factory} is valid with valid attributes" do
    user = build(user_factory)
    expect(user).to be_valid
  end

  # check if user is invalid without a name
  it "#{user_factory} requires a name" do
    user.name = nil
    expect(user).not_to be_valid
  end

  # Check if email is present
  it "#{user_factory} requires an email" do
    user.email = nil
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  # Check if email is unique
  it "#{user_factory} requires a unique email" do
    user.save!
    new_user = build(user_factory, email: user.email)
    expect(new_user).not_to be_valid
    expect(new_user.errors[:email]).to include("has already been taken")
  end

  # Check if email is valid
  it "#{user_factory} requires a valid email" do
    user.email = "invalid_email"
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  #check if user is valid with the possible null attributes
  it "#{user_factory} is valid with possible null attributes" do
    user = build(user_factory)
    user.address = nil
    user.cap = nil
    user.province = nil
    user.city = nil
    user.country = nil
    expect(user).to be_valid
  end

  #Check length of attributes
  it "#{user_factory} requires a name with a maximum length of 255 characters" do
    user.name = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a surname with a maximum length of 255 characters" do
    user.surname = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:surname]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires an email with a maximum length of 255 characters" do
    user.email = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a phone with a maximum length of 255 characters" do
    user.phone = "1" * 256
    expect(user).not_to be_valid
    expect(user.errors[:phone]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires an address with a maximum length of 255 characters" do
    user.address = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:address]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a cap with a maximum length of 255 characters" do
    user.cap = "1" * 256
    expect(user).not_to be_valid
    expect(user.errors[:cap]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a province with a maximum length of 255 characters" do
    user.province = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:province]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a city with a maximum length of 255 characters" do
    user.city = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:city]).to include("must be at most 255 characters")
  end

  it "#{user_factory} requires a country with a maximum length of 255 characters" do
    user.country = "a" * 256
    expect(user).not_to be_valid
    expect(user.errors[:country]).to include("must be at most 255 characters")
  end

  # can't have a type different from UserNormal, UserOrganizer or CompanyOrganizer
  it "#{user_factory} requires a type to be one of the following: UserNormal, UserOrganizer, CompanyOrganizer" do
    user.type = "User"
    expect(user).not_to be_valid
    expect(user.errors[:type]).to include("must be one of the following: UserNormal, UserOrganizer, CompanyOrganizer")
  end

  # TEST for password
  it "#{user_factory} requires a password with a minimum length of 6 characters" do
    user.password = "a" * 5
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
  end

  # TEST for password confirmation
  it "#{user_factory} requires a password confirmation to match the password" do
    user.password_confirmation = "different_password"
    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to include("doesn't match Password")
  end

  # TEST the methods of the class user
  describe "#organizer?" do
    it "returns true if the user is an organizer" do
      user = FactoryBot.create(:user_organizer)
      user2 = FactoryBot.create(:company_organizer)
      expect(user.organizer?).to eq(true)
      expect(user2.organizer?).to eq(true)
    end

    it "returns false if the user is not an organizer" do
      user = FactoryBot.create(:user_normal)
      expect(user.organizer?).to eq(false)
    end
  end


  describe "#normal?" do
  it "returns true if the user is a normal user" do
    user = FactoryBot.create(:user_normal)
    expect(user.normal?).to eq(true)
  end

  it "returns false if the user is not a normal user" do
    user = FactoryBot.create(:user_organizer)
    user2 = FactoryBot.create(:company_organizer)
    expect(user.normal?).to eq(false)
    expect(user2.normal?).to eq(false)
  end
end

describe "#get_name" do
    it "returns the full name for normal users" do
      user = FactoryBot.create(:user_normal, name: "John", surname: "Doe")
      expect(user.get_name).to eq("John Doe")
    end

    it "returns only the name for company organizers" do
      user = FactoryBot.create(:company_organizer, name: "Company X")
      expect(user.get_name).to eq("Company X")
    end
  end
end
