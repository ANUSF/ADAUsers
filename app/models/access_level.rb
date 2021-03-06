class AccessLevel < ActiveRecord::Base
  set_table_name 'accesslevel'
  set_primary_keys :datasetID, :fileID, :accessLevel

  belongs_to :series, :class_name => "StatementEjb", :foreign_key => "datasetID", :primary_key => "objectId", :conditions => {:subjectType => 'fCatalog'}

  CATEGORY_ACCESS_LEVELS = {:a => ['A', 'G'], :b => ['B', 'S']}

  scope :cat_a, where(:accessLevel => ['A', 'G'], :fileID => nil)
    .where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)")
    .group(:datasetID)
    .order('datasetID ASC')

  scope :cat_b, where(:accessLevel => ['B', 'S'], :fileID => nil)
    .group(:datasetID)
    .order('datasetID ASC')

  scope :ada_ddi, where("datasetID LIKE 'au.edu.anu.ada.ddi.%%'")

  scope :files_for_dataset, (lambda do |datasetID, category|
    where("datasetID = ? AND accessLevel IN (?) AND fileID IS NOT NULL", datasetID, CATEGORY_ACCESS_LEVELS[category]).order('fileID')
  end)
  scope :not_files, where("fileID IS NULL")

  def self.dataset_is_restricted(datasetID)
    accessLevels = self.where(:datasetID => datasetID)
    accessLevelCategories = accessLevels.map { |al| al.accessLevel }

    accessLevelCategories.include? 'B' or accessLevelCategories.include? 'S'
  end

  def user_permission(user)
    model = (self.category == :a ? UserPermissionA : UserPermissionB)
    p = model.find_or_initialize_by_userID_and_datasetID_and_fileID(user.user, self.datasetID, self.fileID)
    p.permissionvalue = 0 if p.new_record?
    p
  end

  def dataset_local_id
    self.datasetID =~ /([^\.]*)$/
    $1
  end

  def dataset_description
    "%s - %s" % [self.dataset_local_id, self.fileContent || self.datasetname]
  end

  def category
    CATEGORY_ACCESS_LEVELS[:a].include?(self.accessLevel) ? :a : :b
  end
end
