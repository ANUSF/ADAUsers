class UserPermissionA < ActiveRecord::Base
  set_table_name 'userpermissiona'

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
end
