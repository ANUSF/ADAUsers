class Admin::UndertakingsController < ApplicationController
  before_filter :require_admin
  layout 'ada_admin'

  def index
    @show_processed_requests = params[:show_processed_requests].to_i || 0

    @undertakings = Undertaking.agreed.order("processed ASC, created_at ASC")
    @undertakings = @undertakings.unprocessed unless @show_processed_requests == 1
    @undertakings = @undertakings.paginate(:page => params[:page])
  end

  def mark_complete
    @undertaking = Undertaking.find(params[:undertaking_id])
    @processed = params[:processed] == "1"
    @undertaking.update_attribute(:processed, @processed)
    flash[:notice] = "That undertaking has been "+(@processed ? "marked as complete." : "reopened.")
    redirect_to admin_undertakings_path
  end
end
