class CompanyOrganizer < User
    # these are the organizer that are simple company 
    #Validation of the model
    validates :name, :email, :phone, presence: true

    validates :phone, numericality: { only_integer: true, greater_than: 0, message: "must be formed by numbers" }

  end