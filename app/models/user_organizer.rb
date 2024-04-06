class UserOrganizer < User
  #These are the organizer that are simple users
  #Validation of the model
  validates :name, :surname, :email, :date_of_birth, :phone, presence: true
  validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validates :phone, numericality: { only_integer: true, greater_than: 0, message: "must be formed by numbers" }
  validate :date_of_birth_cannot_be_in_the_future
end
