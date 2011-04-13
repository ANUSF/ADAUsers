class Admin::UndertakingsController < ApplicationController
  before_filter :require_admin

  def index
    @undertakings = Undertaking.agreed.order("processed ASC, created_at ASC").paginate(:page => params[:page])
  end

  def mark_complete
    @undertaking = Undertaking.find(params[:undertaking_id])
    @undertaking.update_attribute(:processed, params[:processed] == "1")
    redirect_to admin_undertakings_path, :notice => "That undertaking has been marked as complete."
  end
end
