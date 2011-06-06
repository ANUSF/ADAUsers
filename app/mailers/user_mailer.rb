class UserMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  def register_email(user, password)
    TemplateMailer.template_email(user.email, 'registration', {:user => user, :password => password})
  end

  def reset_password_email(user)
    TemplateMailer.template_email(user.email, 'reset_password', {:user => user})
  end

  def change_password_email(user, new_password)
    TemplateMailer.template_email(user.email, 'change_password', {:user => user, :new_password => new_password})
  end
end
