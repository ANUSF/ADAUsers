class UserPermissionA < ActiveRecord::Base
  set_table_name 'userpermissiona'
  set_primary_keys :userID, :datasetID, :fileID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
  belongs_to :access_level, :primary_key => :datasetID, :foreign_key => :datasetID

  default_scope order('datasetID')
  scope :accessible, where(:permissionvalue => 1)
  scope :pending, where(:permissionvalue => 0)
  scope :without_parented_files, where("fileID IS NULL OR (SELECT COUNT(*) FROM userpermissiona upa WHERE userID=userpermissiona.userID AND datasetID=userpermissiona.datasetID AND fileID IS NULL) = 0")

  def user_has_access
    self.user.permissions_a.where(:datasetID => self.datasetID, :fileID => nil, :permissionvalue => 1).present?
  end

  def permissionvalue
    read_attribute_before_type_cast(:permissionvalue)
  end
end
