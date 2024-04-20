class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # validates the length of all the possible fields:
  validates :name, :surname, :email, :phone, :address, :cap, :province, :city, :country, length: { maximum: 255, too_long: "must be at most %{count} characters" }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :name, :email, presence: true
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
  has_many :created_events, class_name: "Event", foreign_key: "user_id"  # dependent: :destroy
  # A user can have many notifications
  has_many :notifications # dependent: :destroy

  # Manually managing the destructions of related objects -> in order to create the notifications
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

  # Method to notify the event owners and destroy the subscriptions
  # method called before deleting an user account
  def notify_event_owners_and_destroy_subscriptions
    if !organizer?
      # First, notify the event owners
      subscriptions.each do |subscription|
        event = subscription.event
        NotificationService.create_notification_unsubscribe_delete(user: self, event: event, user_organizer: event.user)
      end

      # Then, manually destroy subscriptions
      subscriptions.destroy_all
    end

    #if the user is an organizer a notification of his events deletion must be sent
    if organizer?
      created_events.each do |event|
        # only send notification on upcoming events
        if !event.past?
          NotificationService.create_notification_delete_event(user_organizer: self, event: event)
        end
      end
      #Now the events can be deleted
      created_events.destroy_all
    end

    # Finally, destroy all notifications
    notifications.destroy_all
  end

  protected

  def date_of_birth_cannot_be_in_the_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be in the future")
    end
  end
end
