class UserOrganizer < User
    #These are the organizer that are simple users
    #Validation of the model
    validates :name, :surname, :email, :date_of_birth, :phone, presence: true
    validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :phone, numericality: { only_integer: true, greater_than: 0, message: "must be formed by numbers" }

    # An organizer can create many events (and the events has a foreign key 'user_id')
    # when and organizer deletes its account all the events created by him will be deleted
    has_many :events, foreign_key: "user_id", dependent: :destroy
  end