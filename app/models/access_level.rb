class AccessLevel < ActiveRecord::Base
  set_table_name 'accesslevel'
  set_primary_keys :datasetID, :fileID, :accessLevel

  scope :cat_a, where(:accessLevel => ['A', 'G'], :fileID => nil).where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)").order('datasetID ASC')

  def self.files_for_dataset(datasetID)
    # TODO: Parameter to choose unrestricted/restricted
    where("datasetID = ? AND accessLevel IN ('A', 'G') AND fileID IS NOT NULL", datasetID).order('fileID')
  end

  def dataset_description
    self.datasetID =~ /([^\.]*)$/
    "%s - %s" % [$1, self.fileContent || self.datasetname]
  end
end
