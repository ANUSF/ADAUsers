class Admin::EmailsController < ApplicationController
  before_filter :require_admin
end
