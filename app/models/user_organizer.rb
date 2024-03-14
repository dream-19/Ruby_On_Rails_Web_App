class UserOrganizer < User
    #These are the organizer that are simple users
    #Validation of the model
    validates :name, :surname, :email, :date_of_birth, :phone, presence: true
    validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    
    # An organizer can create many events
    has_many :events, dependent: :destroy
  end