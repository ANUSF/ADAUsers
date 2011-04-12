class UserMailer < ActionMailer::Base
  default :from => "ASSDA <assda@anu.edu.au>"

  def register_email(user, password)
    @user = user
    @password = password

    mail(:to => user.email, :subject => "User Nesstar Registration")
  end

  def reset_password_email(user, new_password)
    @user = user
    @new_password = new_password

    mail(:to => user.email, :subject => "ASSDA User Password Reset")
  end

  def change_password_email(user, new_password)
    @user = user
    @new_password = new_password

    mail(:to => user.email, :subject => "ASSDA User Registration - password changed")
  end
end
