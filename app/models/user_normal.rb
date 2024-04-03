class UserNormal < User
    # These are the accounts of normal users: they are used to subscribe to events
    #Validation of the model
    validates :name, :surname, :email, :date_of_birth, presence: true
    validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
    
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validate :date_of_birth_cannot_be_in_the_future


   
    
   
  end