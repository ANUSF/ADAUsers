class Admin::EmailsController < ApplicationController
  before_filter :require_admin

  def create
    @email = Email.new(params[:email])
    if @email.valid?
      TemplateMailer.custom_email(@email).deliver
      redirect_to params[:redirect_to]
    else
      render 'new'
    end
  end

end
