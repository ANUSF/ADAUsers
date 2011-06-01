class TemplateMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  # Mail an email stored in an Email object
  def custom_email(email)
    mail(:from => email.from, :to => email.to, :subject => email.subject) do |format|
      format.html { render :text => email.body }
    end
  end

end
