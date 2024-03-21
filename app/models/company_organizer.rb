class CompanyOrganizer < User
    # these are the organizer that are simple company 
    #Validation of the model
    validates :name, :email, :phone, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :phone, numericality: { only_integer: true, greater_than: 0, message: "must be formed by numbers" }

  end