class Subscription < ApplicationRecord
  #validation of the subscription
  validates :subscription_time, :subscription_date, presence: true
  #subscription date must be in a date format
  validates :subscription_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validate :validate_time

  belongs_to :user
  belongs_to :event

  def validate_time
    if subscription_time.present?
      formatted_time = subscription_time.strftime('%H:%M:%S')
    
      # Regex to match the 'HH:MM:SS' format
      time_format_regex = /\A([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\z/
      
      unless formatted_time.match(time_format_regex)
        errors.add(:subscription_time, "is not in the correct format")
      end
    end
  end
  

end
