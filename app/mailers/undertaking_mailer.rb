class UndertakingMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  def confirm_to_admin_email(undertaking)
    TemplateMailer.template_email(self.default_params[:from], 'undertaking_acknowledgement_admin',
                                  {:undertaking => undertaking})
  end

  def confirm_to_user_email(undertaking)
    TemplateMailer.template_email(undertaking.user.email, 'undertaking_acknowledgement_user',
                                  {:undertaking => undertaking})
  end

end
