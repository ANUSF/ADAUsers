class StatementEjb < ActiveRecord::Base
  establish_connection "#{Rails.env}_nesstar"
  set_table_name 'StatementEJB'
  set_primary_key :id

  has_many :access_levels, :foreign_key => "datasetID", :primary_key => "objectId"

  scope :series, where(:subjectType => 'fCatalog').group("subjectId").order('subjectId ASC')

  def self.populated_restricted_series
    # TODO: On production environment, implement this with a join
    #       See AccessLevelsController for an explanation
    self.series.select { |s| s.access_levels.where(:accessLevel => ['B', 'S']).present? }
  end
end
