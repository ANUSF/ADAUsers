class UserMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  def register_email(user, password)
    @user = user
    @password = password

    mail(:to => user.email, :subject => "User Nesstar Registration")
  end

  def reset_password_email(user)
    @user = user

    mail(:to => user.email, :subject => "ASSDA User Password Reset")
  end

  def change_password_email(user, new_password)
    @user = user
    @new_password = new_password

    mail(:to => user.email, :subject => "ASSDA User Registration - password changed")
  end

  def pending_datasets_access_approved_email(user, category)
    @user = user
    @datasets = category == :a ? @user.datasets_cat_a_pending_to_grant : @user.datasets_cat_b_pending_to_grant
    @datasets.map! { |datasetID| AccessLevel.find_by_datasetID(datasetID) }

    mail(:to => user.email, :subject => "Access approved for #{category == :a ? "General" : "Restricted"} dataset(s)")
  end
end
