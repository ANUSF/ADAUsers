class UserRole < ActiveRecord::Base
  set_table_name 'userRole'

  belongs_to :user, :primary_key => :user, :foreign_key => :id
  belongs_to :role, :class_name => 'RoleEjb', :primary_key => :id, :foreign_key => :roleID
end
