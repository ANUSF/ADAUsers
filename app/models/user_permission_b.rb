class UserPermissionB < ActiveRecord::Base
  set_table_name 'userpermissionb'

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
end
