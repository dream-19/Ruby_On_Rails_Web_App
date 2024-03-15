class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # validates the length of all the possible fields:
  validates :name, :surname,:email, :phone,:address, :cap, :province, :city, :state, length: { maximum: 255, too_long: "must be at most %{count} characters" }


  validates :type, presence: true
  # The type of the user must be one of the following: UserNormal, UserOrganizer, CompanyOrganizer
  validates :type, inclusion: { in: UserRoles::ALL_ROLES, message: "must be one of the following: #{UserRoles::ALL_ROLES.join(', ')}" }

end



