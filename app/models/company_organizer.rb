class CompanyOrganizer < User
    # these are the organizer that are simple company 
    #Validation of the model
    validates  :phone, presence: true

    #company organizer can't have a surname or a date_of_birth
    validates :surname, absence: true
    validates :date_of_birth, absence: true

  end