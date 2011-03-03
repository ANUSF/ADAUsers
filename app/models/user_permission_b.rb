class UserPermissionB < ActiveRecord::Base
  set_table_name 'userpermissionb'
  set_primary_keys :userID, :datasetID, :fileID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
  belongs_to :access_level, :primary_key => :datasetID, :foreign_key => :datasetID

  scope :accessible, where("permissionvalue > 0")
  scope :pending, where(:permissionvalue => 0)

  PERMISSION_VALUES = {:browse => 1, :analyse => 3, :download => 2}
  PERMISSION_VALUE_S = {1 => "Browse", 2 => "Download", 3 => "Analyse", 6 => "Analyse + Download"}

  def user_has_access
    self.user.permissions_b.where("datasetID = ? AND fileID IS NULL AND permissionvalue > 0", self.datasetID).present?
  end
end
