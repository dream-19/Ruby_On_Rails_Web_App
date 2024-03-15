class CompanyOrganizer < User
    # these are the organizer that are simple company 
    #Validation of the model
    validates :name, :email, :phone, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    
    # An organizer can create many events (and the events has a foreign key 'user_id')
    # when and organizer deletes its account all the events created by him will be deleted
    has_many :events, foreign_key: "user_id", dependent: :destroy
  end