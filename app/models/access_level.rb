class AccessLevel < ActiveRecord::Base
  set_table_name 'accesslevel'

  scope :cat_a, where(:accessLevel => ['A', 'G'], :fileID => nil).where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)").order('datasetID ASC')

  def dataset_description
    self.datasetID =~ /([^\.]*)$/
    "%s - %s" % [$1, self.fileContent || self.datasetname]
  end
end
