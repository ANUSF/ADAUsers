class UserPermissionB < ActiveRecord::Base
  set_table_name 'userpermissionb'
  set_primary_keys :userID, :datasetID, :fileID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
  belongs_to :access_level, :primary_key => :datasetID, :foreign_key => :datasetID

  default_scope order('datasetID')
  scope :accessible, where("permissionvalue > 0")
  scope :pending, where(:permissionvalue => 0)
  scope :without_parented_files, where("fileID IS NULL OR (SELECT COUNT(*) FROM userpermissionb upb WHERE userID=userpermissionb.userID AND datasetID=userpermissionb.datasetID AND fileID IS NULL) = 0")

  PERMISSION_VALUES = {:browse => 1, :analyse => 3, :download => 2}
  PERMISSION_VALUE_S = {1 => "Browse", 2 => "Download", 3 => "Analyse", 6 => "Analyse + Download"}

  # [:browse, :analyse, :download] --> 6
  def self.permission_value(ps)
    ps.inject(1) { |product, p| product * PERMISSION_VALUES[p] }
  end

  def user_has_access
    self.user.permissions_b.where("datasetID = ? AND fileID IS NULL AND permissionvalue > 0", self.datasetID).present?
  end
end
