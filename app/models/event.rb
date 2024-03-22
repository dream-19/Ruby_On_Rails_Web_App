class Event < ApplicationRecord
  #validation of the event
  validates :name, :beginning_time, :beginning_date, :ending_time, :ending_date, :max_participants, :address, :cap, :province,:city, :country, presence: true
  validates :beginning_date, :ending_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format YYYY-MM-DD" }
  validates :name,:address, :cap, :province, :city, :country, length: { maximum: 255, too_long: "must be at most %{count} characters" }
  validates :description, length: { maximum: 500, too_long: "must be at most %{count} characters"  }
  validates :max_participants, numericality: { only_integer: true, greater_than: 0, message: "must be an integer > 0" }

  before_save :apply_camel_case
  validate :validate_time_date

  # Return the events that are upcoming
  def self.upcoming
    where("ending_date >= ?", Date.today)
  end

  # Return the events that are past
  def self.past 
    where("ending_date < ?", Date.today)
  end 

  private

  # Validate the time format and date 
  # The time format must be in the 'HH:MM:SS' format
  # The beginning date must be before the ending date
  # The beginning time must be before the ending time
  # The ending date cannot be before today
  def validate_time_date
    formatted_time_beginning = beginning_time.strftime('%H:%M:%S') if beginning_time.present?
    formatted_time_ending = ending_time.strftime('%H:%M:%S') if ending_time.present?
  
    # Regex to match the 'HH:MM:SS' format
    time_format_regex = /\A([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\z/

    unless time_format_regex.match?(formatted_time_beginning) 
      errors.add(:beginning_time, 'does not have a valid time component (HH:MM:SS)')
    end

    unless time_format_regex.match?(formatted_time_ending)
      errors.add(:ending_time, 'does not have a valid time component (HH:MM:SS)')
    end

    if ending_date.present?
      errors.add(:ending_date, 'cannot be before today') if ending_date < Date.today
      if beginning_date.present? 
        errors.add(:beginning_date, 'must be before the ending date') if beginning_date > ending_date
        if beginning_time.present? && ending_time.present?
          errors.add(:beginning_time, 'must be before the ending time') if beginning_date == ending_date && beginning_time >= ending_time
        end 
      end
    end

  end

   #Apply camel case to fields
   def apply_camel_case
    self.country = to_title_case(country) if country.present?
    self.city = to_title_case(city) if city.present?
    self.province = to_title_case(province) if province.present?
    self.address = to_title_case(address) if address.present?
  end

  def to_title_case(str)
    str.split.map(&:capitalize).join(' ')
  end

  belongs_to :user

  # An event can have many users subscribe to it
  has_many :subscriptions, dependent: :destroy
 
  # Through subscriptions, an event can have many subscribers (users)
  has_many :subscribers, through: :subscriptions, source: :user
end
