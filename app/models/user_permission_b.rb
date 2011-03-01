class UserPermissionB < ActiveRecord::Base
  set_table_name 'userpermissionb'
  set_primary_keys :userID, :datasetID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
  belongs_to :access_level, :primary_key => :datasetID, :foreign_key => :datasetID

  scope :accessible, where("permissionvalue > 0")
  scope :pending, where(:permissionvalue => 0)
end
