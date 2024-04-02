class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :message, presence: true
  validates :notification_type, presence: true


  # number of read notifications of an user
 

    def self.read
      where(read: true).count
    end


  #number of unread notifications of an user
  def self.unread
    where(read: false).count
  end

end
