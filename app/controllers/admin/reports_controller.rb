class Admin::ReportsController < ApplicationController
  before_filter :require_admin

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(params[:report])
    @result = @report.generate

    if params[:commit] == 'CSV Report'
      render_csv "report", "admin/reports/create.csv.erb"
    end
  end

end
