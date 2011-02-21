class UserPermissionA < ActiveRecord::Base
  set_table_name 'userpermissiona'
  set_primary_keys :userID, :datasetID, :fileID

  belongs_to :user, :primary_key => :user, :foreign_key => :userID
  belongs_to :access_level, :primary_key => :datasetID, :foreign_key => :datasetID

  scope :accessible, where(:permissionvalue => 1)
  scope :pending, where(:permissionvalue => 0)


  def user_has_access
    self.user.permissions_a.where(:datasetID => self.datasetID, :fileID => nil, :permissionvalue => 1).present?
  end
end
