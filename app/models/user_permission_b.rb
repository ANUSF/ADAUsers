class UserPermissionB < ActiveRecord::Base
  set_table_name 'userpermissionb'
  set_primary_keys :userID, :datasetID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
end
