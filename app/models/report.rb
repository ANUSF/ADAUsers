class Report
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :start_date, :end_date, :report_type, :dataset

  TYPES = [['Analysis/downloads Report', 'report_ad'],
           ['Registration Report', 'u_reg'],
           ['Analysis by Institutions Report', 'inst_analysis'],
           ['Downloads by Institutions Report', 'inst_download'],
           ['Analysis by Position Type Report', 'a_pos_type'],
           ['Downloads by Position Type Report', 'd_pos_type'],
           ['Analysis by Institutions/Position Type Report', 'a_inst_pos_type'],
           ['Downloads by Institutions/Position Type Report', 'd_inst_pos_type'],
           ['Analysis by User Report', 'a_user'],
           ['Downloads by User Report', 'd_user'],
           ['Usage by Institution Report', 'join_inst'],
           ['Usage by Position Type Report', 'join_pos'],
           ['Depositors Report', 'depositors'],
           ['Usage of Datasets', 'datasets_usage'],
           ['Dataset Usage by Institution Report', 'dataset_join_inst'],
           ['Dataset Usage by Position Type Report', 'dataset_join_pos']]


  def initialize(attributes={})
    attributes ||= {}
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  # Run the report and return the resulting SQL result object
  def generate
    self.send(self.report_type)
  end

  def persisted?
    false
  end


  # -- Report queries
  def report_ad
    sanitize_and_exec("SELECT a.method, Count(a.method) AS numberof
                       FROM #{db('logs')}.anulogs a
                       WHERE a.date_processed >= ? and a.date_processed <= ?
                       GROUP BY a.method", self.start_date, self.end_date)
  end

  def inst_analysis
    sanitize_and_exec("SELECT CONCAT('\"', u.institution,'\"') As Institution, Count(a.method) AS Analisedd
                       FROM #{db()}.userdetails u, (SELECT l.name, l.method, l.date_processed As dProcess
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= ? And
                       l.date_processed <= ? AND l.method = \"ANALIZE\") a
                       WHERE (a.name = u.user)
                       GROUP BY u.institution", self.start_date, self.end_date)
  end


  protected

  def db(name=nil)
    db = (name ? "#{Rails.env}_#{name}" : Rails.env)
    ActiveRecord::Base.configurations[db]["database"]
  end

  def sanitize_and_exec(query, *args)
    sql = ActiveRecord::Base.__send__(:sanitize_sql, [query]+args, '')
    ActiveRecord::Base.connection.execute(sql)
  end
end
