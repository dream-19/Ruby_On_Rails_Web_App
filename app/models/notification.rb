class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :message, presence: true
  validates :notification_type, presence: true

end
