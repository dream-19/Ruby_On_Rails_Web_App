class CompanyOrganizer < User
    # these are the organizer that are simple company 
    #Validation of the model
    validates :name, :email, :phone, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    
    # An organizer can create many events
    has_many :events, dependent: :destroy
  end