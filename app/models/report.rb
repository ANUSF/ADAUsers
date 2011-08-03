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
    self.start_date = Date.parse(self.start_date)
    self.end_date = Date.parse(self.end_date)

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
    sanitize_and_exec("SELECT CONCAT('\"', u.institution,'\"') As Institution, Count(a.method) AS Analised
                       FROM #{db}.userdetails u, (SELECT l.name, l.method, l.date_processed As dProcess
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= ? And
                       l.date_processed <= ? AND l.method = \"ANALIZE\") a
                       WHERE (a.name = u.user)
                       GROUP BY u.institution", self.start_date, self.end_date)
  end

  def inst_download
    sanitize_and_exec("SELECT CONCAT('\"', u.institution,'\"') As Institution, Count(a.method) AS Download
                       FROM #{db}.userdetails u, (SELECT l.name, l.method, l.date_processed AS dProcess
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= ? AND
                       l.date_processed <= ? AND l.method = \"DOWNLOAD\") a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution", self.start_date, self.end_date)
  end

  def a_pos_type
    sanitize_and_exec("SELECT b.position, Count(a.name) AS ANumber
                       FROM #{db('logs')}.anulogs a, #{db}.userdetails b
                       WHERE a.date_processed >= ? AND
                       a.date_processed <= ? AND a.method = \"ANALIZE\"
                       and a.name = b.user
                       GROUP BY b.position", self.start_date, self.end_date)
  end

  def d_pos_type
    sanitize_and_exec("SELECT b.position, Count(a.name) AS ANumber
                       FROM #{db('logs')}.anulogs a, #{db}.userdetails b
                       WHERE a.date_processed >= ? AND
                       a.date_processed <= ? AND a.method = \"DOWNLOAD\"
                       and a.name = b.user
                       GROUP BY b.position", self.start_date, self.end_date)
  end

  def a_inst_pos_type
    sanitize_and_exec("SELECT CONCAT('\"', t1.institution,'\"') As Institution, COALESCE(t1.UG, '0') As UndergradSt,
                       COALESCE(t2.PG, '0') As PostgradSt, COALESCE(t3.R, '0') As Researcher,
                       COALESCE(t4.RA, '0') As RAssist, COALESCE(t5.O, '0') As Other
                       FROM
                       (SELECT k.institution, m.UG
                       FROM (SELECT u.institution, Count(a.method) AS UG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS UG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user) and u.position = 'Undergraduate student'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t1,
                       (SELECT k.institution, m.PG
                          FROM (SELECT u.institution, Count(a.method) AS PG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS PG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user) and u.position = 'Postgraduate student'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t2,
                       (SELECT k.institution, m.R
                       FROM (SELECT u.institution, Count(a.method) AS R
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS R
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user) and u.position = 'Researcher'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t3,
                       (SELECT k.institution, m.RA
                       FROM (SELECT u.institution, Count(a.method) AS RA
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS RA
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user) and u.position = 'Research Assistant'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t4,
                       (SELECT k.institution, m.O
                       FROM (SELECT u.institution, Count(a.method) AS O
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS O
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'ANALIZE' ) a
                       WHERE (a.name =u.user) and u.position = 'Other'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t5
                       WHERE t1.institution = t2.institution  AND t1.institution = t3.institution
                       AND t1.institution = t4.institution  AND t1.institution = t5.institution",
                      {:start_date => self.start_date, :end_date => self.end_date})
  end

  def d_inst_pos_type
    sanitize_and_exec("SELECT CONCAT('\"', t1.institution,'\"') As Institution, COALESCE(t1.UG, '0') As UndergradSt,
                       COALESCE(t2.PG, '0') As PostgradSt, COALESCE(t3.R, '0') As Researcher,
                       COALESCE(t4.RA, '0') As RAssist, COALESCE(t5.O, '0') As Other
                       FROM
                       (SELECT k.institution, m.UG
                       FROM (SELECT u.institution, Count(a.method) AS UG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS UG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user) and u.position = 'Undergraduate student'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t1,
                       (SELECT k.institution, m.PG
                       FROM (SELECT u.institution, Count(a.method) AS PG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS PG
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user) and u.position = 'Postgraduate student'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t2,
                       (SELECT k.institution, m.R
                       FROM (SELECT u.institution, Count(a.method) AS R
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS R
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user) and u.position = 'Researcher'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t3,
                       (SELECT k.institution, m.RA
                       FROM (SELECT u.institution, Count(a.method) AS RA
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS RA
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user) and u.position = 'Research Assistant'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t4,
                       (SELECT k.institution, m.O
                       FROM (SELECT u.institution, Count(a.method) AS O
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user)
                       GROUP BY u.institution) k left outer join
                      ( SELECT u.institution, Count(a.method) AS O
                       FROM #{db}.userdetails u, (SELECT l.name, l.method
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= :start_date AND
                       l.date_processed <= :end_date AND l.method = 'DOWNLOAD' ) a
                       WHERE (a.name =u.user) and u.position = 'Other'
                       GROUP BY u.institution) m  on k.institution = m.institution ) t5
                       WHERE t1.institution = t2.institution  AND t1.institution = t3.institution
                       AND t1.institution = t4.institution  AND t1.institution = t5.institution",
                      {:start_date => self.start_date, :end_date => self.end_date})
  end

  def proto
    sanitize_and_exec("")
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
