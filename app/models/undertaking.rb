class Undertaking < ActiveRecord::Base
  belongs_to :user, :primary_key => :user, :foreign_key => :user_user

  has_and_belongs_to_many :datasets,
    :class_name => "AccessLevel",
    :finder_sql => 'SELECT * FROM "accesslevel" INNER JOIN "access_levels_undertakings" ON ("accesslevel".datasetID = "access_levels_undertakings".datasetID) WHERE (("access_levels_undertakings"."undertaking_id" = #{id}))',
    :insert_sql => 'INSERT INTO "access_levels_undertakings" ("datasetID", "undertaking_id") VALUES (\'#{record.datasetID}\', #{id})'


  validates_presence_of :user, :intended_use_type, :intended_use_description, :funding_sources, :datasets
  validates_presence_of :email_supervisor, :if => lambda { |rec| rec.intended_use_type and rec.intended_use_type.include? :thesis }
  # TODO: Validate email address

  serialize :intended_use_type

  def self.intended_use_options
    {:government => "Government research",
     :pure => "Pure research",
     :commercial => "Commercial research",
     :consultancy => "Research consultancy",
     :teaching => "Teaching purposes",
     :thesis => "Thesis or coursework",
     :personal => "Personal interest"}
  end
end
