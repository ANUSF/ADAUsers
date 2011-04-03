class AccessLevel < ActiveRecord::Base
  set_table_name 'accesslevel'
  set_primary_keys :datasetID, :fileID, :accessLevel

  CATEGORY_ACCESS_LEVELS = {:a => ['A', 'G'], :b => ['B', 'S']}

  scope :cat_a, where(:accessLevel => ['A', 'G'], :fileID => nil)
    .where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)")
    .order('datasetID ASC')

  scope :cat_b, where(:accessLevel => ['B', 'S'], :fileID => nil).order('datasetID ASC')

  scope :files_for_dataset, (lambda do |datasetID, category|
    where("datasetID = ? AND accessLevel IN (?) AND fileID IS NOT NULL", datasetID, CATEGORY_ACCESS_LEVELS[category]).order('fileID')
  end)
  scope :not_files, where("fileID IS NULL")

  def user_permission(user)
    model = (self.category == :a ? UserPermissionA : UserPermissionB)
    p = model.find_or_initialize_by_userID_and_datasetID_and_fileID(user.user, self.datasetID, self.fileID)
    p.permissionvalue = 0 if p.new_record?
    p
  end

  def dataset_description
    self.datasetID =~ /([^\.]*)$/
    "%s - %s" % [$1, self.fileContent || self.datasetname]
  end

  def category
    CATEGORY_ACCESS_LEVELS[:a].include?(self.accessLevel) ? :a : :b
  end
end
