class Undertaking < ActiveRecord::Base
  belongs_to :user, :primary_key => :user, :foreign_key => :user_user

  has_and_belongs_to_many :datasets,
    :class_name => "AccessLevel",
    :finder_sql => proc { "SELECT * FROM accesslevel INNER JOIN access_levels_undertakings ON (accesslevel.datasetID = access_levels_undertakings.datasetID) WHERE (access_levels_undertakings.undertaking_id = #{id})" },
    :insert_sql => proc { |record| "INSERT INTO access_levels_undertakings (datasetID, undertaking_id) VALUES ('#{record.datasetID}', #{id})" },
    :delete_sql => proc { |record| "DELETE FROM access_levels_undertakings WHERE datasetID = '#{record.datasetID}' AND undertaking_id = #{id}" },
    :uniq => true

  scope :agreed, where("agreed = " + ActiveRecord::Base.connection.quoted_true)
  scope :unprocessed, where("processed IS NULL OR processed = " +
                            ActiveRecord::Base.connection.quoted_false)

  validates_presence_of :user

  validates :intended_use_type, {
    :presence => {
      :message => 'please specify your intended use of the data',
      :if => lambda { |rec| rec.intended_use_other.nil? or rec.intended_use_other.blank?}}}
 
  validates :intended_use_description, {
    :presence => {
      :message => 'please enter your description of intended use'}}

  validates :funding_sources, {
    :presence => {
      :message => 'please enter your funding source(s)'}}

  validates :datasets, {
    :presence => {
      :message => 'please select one or more datasets'}}

  validates :email_supervisor, {
    :presence => {
      :message => "please enter your supervisor's email address"}}


  serialize :intended_use_type
  
  attr_accessor :catalogue

  after_save :update_user

  def self.intended_use_options
    {:government => "Government research",
     :pure => "Pure research",
     :commercial => "Commercial research",
     :consultancy => "Research consultancy",
     :teaching => "Teaching purposes",
     :thesis => "Thesis or coursework",
     :personal => "Personal interest"}
  end

  # Scrub blank value from intended_use_type added by Formtastic check boxes input
  def intended_use_type=(intended_use_type)
    write_attribute(:intended_use_type, intended_use_type.reject { |t| t.nil? || t.blank? })
  end

  def is_restricted; is_restricted? end
  def agreed;        agreed?        end
  def processed;     processed?     end

  def update_user
    self.user.signed_undertaking_form = User::UNDERTAKING_REQUESTED unless self.user.signed_undertaking_form?
    self.user.save!

    # Add datasets as pending if not present
    self.user.add_datasets!(self.datasets.map {|d| d.datasetID}, self.is_restricted ? :b : :a, {0 => 1})
  end

  def dataset_descriptions
    self.datasets.map { |d| d.dataset_description }.uniq
  end
end
