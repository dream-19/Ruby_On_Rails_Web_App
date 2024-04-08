class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # validates the length of all the possible fields:
  validates :name, :surname, :email, :phone, :address, :cap, :province, :city, :country, length: { maximum: 255, too_long: "must be at most %{count} characters" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :name,  :email, presence: true
  validates :type, presence: true
  # The type of the user must be one of the following: UserNormal, UserOrganizer, CompanyOrganizer
  validates :type, inclusion: { in: UserRoles::ALL_ROLES, message: "must be one of the following: #{UserRoles::ALL_ROLES.join(", ")}" }

  
  #Relationship
  # Users can have many subscriptions to events (only normal user)
  has_many :subscriptions
  #, dependent: :destroy # (when a user is deleted all the subscriptions are deleted too)

  # Through subscriptions, users can subscribe to many events (only normal user)
  has_many :subscribed_events, through: :subscriptions, source: :event
  # An organizer can create many events (and the events has a foreign key 'user_id')
  # when and organizer deletes its account all the events created by him will be deleted
  has_many :created_events, class_name: "Event", foreign_key: "user_id", dependent: :destroy #(when an organizer is deleted all the events created by him are deleted too)

  # A user can have many notifications
  has_many :notifications, dependent: :destroy

  before_save :apply_camel_case
  before_destroy :notify_event_owners_and_destroy_subscriptions

  #Method to check if the user is an organizer
  def organizer?
    self.type == UserRoles::USER_ORGANIZER || self.type == UserRoles::COMPANY_ORGANIZER
  end

  #chek if the user is a normal user
  def normal?
    self.type == UserRoles::USER_NORMAL
  end

  def get_name
    name = ""
    if self.type == UserRoles::COMPANY_ORGANIZER
      name = self.name
    else
      name = self.name + " " + self.surname
    end
    return name
  end

  #Check if the user is subscribed to an event
  def subscribed?(event)
    subscriptions.where(event_id: event.id).exists?
  end

  #Method to get the number of unread notifications
  def count_unread
    notifications.where(read: false).count
  end

  #Method to get the last n unread notification
  def first_n_unread(n)
    notifications.where(read: false).order(created_at: :desc).limit(n)
  end

  private

  #Apply camel case to fields
  def apply_camel_case
    self.name = to_title_case(name) if name.present?
    self.surname = to_title_case(surname) if surname.present?
    self.country = to_title_case(country) if country.present?
    self.city = to_title_case(city) if city.present?
    self.province = to_title_case(province) if province.present?
    self.address = to_title_case(address) if address.present?
  end

  def to_title_case(str)
    str.split.map(&:capitalize).join(" ")
  end

  def notify_event_owners_and_destroy_subscriptions
    # First, notify the event owners
    subscriptions.each do |subscription|
      event = subscription.event
      NotificationService.create_notification_unsubscribe_delete(user: self, event: event, user_organizer: event.user)
    end

    # Then, manually destroy subscriptions
    subscriptions.destroy_all
  end

  protected

  def date_of_birth_cannot_be_in_the_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be in the future")
    end
  end
end
