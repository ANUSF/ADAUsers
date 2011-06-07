# We don't inherit from ActionMailer::Base here because otherwise the mailer will
# attempt to render the default template after calling TemplateMailer.
class UndertakingMailer
  class << self
    def confirm_to_admin_email(controller, undertaking)
      TemplateMailer.template_email(controller, Email::DEFAULT_FROM, 'undertaking_acknowledgement_admin',
                                    {:undertaking => undertaking})
    end

    def confirm_to_user_email(controller, undertaking)
      TemplateMailer.template_email(controller, undertaking.user.email, 'undertaking_acknowledgement_user',
                                    {:undertaking => undertaking})
    end
  end
end
