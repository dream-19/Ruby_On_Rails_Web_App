# config/initializers/user_roles.rb
module UserRoles
    USER_NORMAL = 'UserNormal'.freeze
    USER_ORGANIZER = 'UserOrganizer'.freeze
    COMPANY_ORGANIZER = 'CompanyOrganizer'.freeze
    ALL_ROLES = [USER_NORMAL, USER_ORGANIZER, COMPANY_ORGANIZER].freeze
  end
  