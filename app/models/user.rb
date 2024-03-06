class User < ApplicationRecord

  #Validation of the model
  validates :name, :surname, :role, :email, :date_of_birth, :address, :cap, :province, :state, :password, presence: true
  validates :phone, allow_blank: true
  validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  # Enum for role
  enum role: { normal: 'normal', organizer: 'organizer' }

  # An organizer can create many events
  has_many :events, dependent: :destroy

  # Users can have many subscriptions to events
  has_many :subscriptions, dependent: :destroy

  # Through subscriptions, users can subscribe to many events
  has_many :subscribed_events, through: :subscriptions, source: :event
end
