class Report

  def self.report_ad(start_date, end_date)
    sanitize_and_exec("SELECT a.method, Count(a.method) AS numberof
                       FROM #{db('logs')}.anulogs a
                       WHERE a.date_processed >= ? and a.date_processed <= ?
                       GROUP BY a.method", start_date, end_date)
  end

  def self.inst_analysis(start_date, end_date)
    sanitize_and_exec("SELECT CONCAT('\"', u.institution,'\"') As Institution, Count(a.method) AS Analisedd
                       FROM #{db()}.userdetails u, (SELECT l.name, l.method, l.date_processed As dProcess
                       FROM #{db('logs')}.anulogs l WHERE l.date_processed >= ? And
                       l.date_processed <= ? AND l.method = \"ANALIZE\") a
                       WHERE (a.name = u.user)
                       GROUP BY u.institution", start_date, end_date)
  end


  protected

  def self.db(name=nil)
    db = (name ? "#{Rails.env}_#{name}" : Rails.env)
    ActiveRecord::Base.configurations[db]["database"]
  end

  def self.sanitize_and_exec(query, *args)
    sql = ActiveRecord::Base.__send__(:sanitize_sql, [query]+args, '')
    puts sql
    ActiveRecord::Base.connection.execute(sql)
  end
end
