# spec/support/shared_examples/user_email_validation.rb
RSpec.shared_examples "email validation" do |user_factory|
    let(:user) { build(user_factory) }
  
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
  end
  