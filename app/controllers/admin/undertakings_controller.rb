class Admin::UndertakingsController < ApplicationController
  before_filter :require_admin

  def index
    @undertakings = Undertaking.all
  end
end
