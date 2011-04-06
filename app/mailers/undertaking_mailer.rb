class UndertakingMailer < ActionMailer::Base
  # TODO: DRY this between mailers
  default :from => "ASSDA <assda@anu.edu.au>"

  def confirm_to_assda_email(undertaking)
    @undertaking = undertaking
    user = undertaking.user

    subject = "General Undertaking form signed by %s (%s)" % [user.user,
                                                              user.confirmed_acspri_member? ? "ACSPRI" : "Non-ACSPRI"]

    # TODO: DRY: Grab default from address
    mail(:to => "ASSDA <assda@anu.edu.au>", :subject => subject)
  end

  def confirm_to_user_email(undertaking)
    @undertaking = undertaking

    mail(:to => undertaking.user.email, :subject => "ASSDA General Undertaking")
  end

end
