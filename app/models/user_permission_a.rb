class UserPermissionA < ActiveRecord::Base
  set_table_name 'userpermissiona'
  set_primary_keys :userID, :datasetID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
end
