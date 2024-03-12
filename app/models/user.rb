class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  validates :type, presence: true
  # The type of the user must be one of the following: NormalUser, UserOrganizer, CompanyOrganizer
  validates :type, inclusion: { in: %w(NormalUser UserOrganizer CompanyOrganizer), message: "must be one of the following: NormalUser, UserOrganizer, CompanyOrganizer" }
 
end

# These are the accounts of normal users: they are used to subscribe to events
class NormalUser < User
  #Validation of the model
  validates :name, :surname, :email, :date_of_birth, presence: true
  validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  
  # Users can have many subscriptions to events
  has_many :subscriptions, dependent: :destroy

  # Through subscriptions, users can subscribe to many events
  has_many :subscribed_events, through: :subscriptions, source: :event
end

#These are the organizer that are simple users
class UserOrganizer < User
  #Validation of the model
  validates :name, :surname, :email, :date_of_birth, presence: true
  validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  
  # An organizer can create many events
  has_many :events, dependent: :destroy
end

# these are the organizer that are simple company 
class CompanyOrganizer < User

  #Validation of the model
  validates :name, :email, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  
  # An organizer can create many events
  has_many :events, dependent: :destroy
end