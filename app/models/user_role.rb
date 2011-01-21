class UserRole < ActiveRecord::Base
  set_table_name 'userRole'

  belongs_to :user, :primary_key => :user, :foreign_key => :id
end
