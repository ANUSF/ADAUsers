class AccessLevel < ActiveRecord::Base
  set_table_name 'accesslevel'
  set_primary_keys :datasetID, :fileID, :accessLevel

  scope :cat_a, where(:accessLevel => ['A', 'G'], :fileID => nil).where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)").order('datasetID ASC')
  scope :cat_b, where(:accessLevel => ['B', 'S'], :fileID => nil).order('datasetID ASC')

  # accessLevel may be :a or :b, which is translated to the database layer: [A, G] or [B, S]
  def self.files_for_dataset(datasetID, accessLevel)
    levels = {:a => ['A', 'G'], :b => ['B', 'S']}
    where("datasetID = ? AND accessLevel IN (?) AND fileID IS NOT NULL", datasetID, levels[accessLevel]).order('fileID')
  end

  def user_permission(user)
    # TODO: Handle restricted datasets (ie. UserPermissionB)
    p = UserPermissionA.find_or_initialize_by_userID_and_datasetID_and_fileID(user.user, self.datasetID, self.fileID)
    p.permissionvalue = 0 if p.new_record?
    p
  end

  def dataset_description
    self.datasetID =~ /([^\.]*)$/
    "%s - %s" % [$1, self.fileContent || self.datasetname]
  end
end
