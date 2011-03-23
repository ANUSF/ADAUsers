class UserMailer < ActionMailer::Base
  default :from => "ASSDA <assda@anu.edu.au>"

  def reset_password_email(user, new_password)
    @user = user
    @new_password = new_password

    mail(:to => user.email, :subject => "ASSDA User Password Reset")
  end
end
