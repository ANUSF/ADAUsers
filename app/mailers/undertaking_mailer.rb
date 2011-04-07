class UndertakingMailer < ActionMailer::Base
  default :from => "ASSDA <assda@anu.edu.au>"

  def confirm_to_admin_email(undertaking)
    @undertaking = undertaking
    user = undertaking.user

    subject = "General Undertaking form signed by %s (%s)" % [user.user,
                                                              user.institution_is_acspri_member ? "ACSPRI" : "Non-ACSPRI"]

    mail(:to => self.default_params[:from], :subject => subject)
  end

  def confirm_to_user_email(undertaking)
    @undertaking = undertaking

    mail(:to => undertaking.user.email, :subject => "ASSDA General Undertaking")
  end

end
