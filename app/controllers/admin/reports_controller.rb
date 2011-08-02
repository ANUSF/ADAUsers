class Admin::ReportsController < ApplicationController
  def new
    @report = Report.new
  end

  def create
    @report = Report.new(params[:report])
    @result = @report.generate

    puts @result.inspect
    puts @result.count

    if params[:commit] == 'HTML Report'
      # ...
    elsif params[:commit] == 'CSV Report'
      render_csv
    end
  end

end
