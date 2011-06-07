# We don't inherit from ActionMailer::Base here because otherwise the mailer will
# attempt to render the default template after calling TemplateMailer.
class UserMailer
  class << self
    def register_email(controller, user, password)
      TemplateMailer.template_email(controller, user.email, 'registration', {:user => user, :password => password})
    end
    
    def reset_password_email(controller, user)
      TemplateMailer.template_email(controller, user.email, 'reset_password', {:user => user})
    end

    def change_password_email(controller, user, new_password)
      TemplateMailer.template_email(controller, user.email, 'change_password', {:user => user, :new_password => new_password})
    end
  end
end
