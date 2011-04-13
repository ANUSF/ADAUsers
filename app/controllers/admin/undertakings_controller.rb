class Admin::UndertakingsController < ApplicationController
  before_filter :require_admin

  def index
    @undertakings = Undertaking.agreed.order("processed ASC, created_at ASC").paginate(:page => params[:page])
  end
end
