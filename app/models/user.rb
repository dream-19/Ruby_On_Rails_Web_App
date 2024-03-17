class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # validates the length of all the possible fields:
  validates :name, :surname,:email, :phone,:address, :cap, :province, :city, :country, length: { maximum: 255, too_long: "must be at most %{count} characters" }


  validates :type, presence: true
  # The type of the user must be one of the following: UserNormal, UserOrganizer, CompanyOrganizer
  validates :type, inclusion: { in: UserRoles::ALL_ROLES, message: "must be one of the following: #{UserRoles::ALL_ROLES.join(', ')}" }


  before_save :apply_camel_case

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
    str.split.map(&:capitalize).join(' ')
  end

end



