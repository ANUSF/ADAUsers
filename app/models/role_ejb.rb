class RoleEjb < ActiveRecord::Base
  set_table_name 'RoleEJB'

  has_many :user_roles, :primary_key => :id, :foreign_key => :roleID
end
