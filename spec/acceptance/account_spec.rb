require File.dirname(__FILE__) + '/acceptance_helper'

feature "Accounts", %q{
  In order to get access to archived data
  As a user
  I want to log in and manage my account
} do

  after(:each) do
    log_out if logged_in?
  end


  scenario "logging in and out" do
    user = User.make

    log_out if logged_in?

    visit "/"
    page.should have_selector("a", :text => "Log in")

    log_in_as(user)
    find("header").should have_content(user.user)
  end

  scenario "viewing user details" do
    user = User.make
    log_in_as(user)
    visit "/users/#{user.user}"

    page.should have_content(user.name)
  end

  scenario "viewing another user's details" do
    access_denied_messages = ["You may not access another user's details.", "You must be logged in to access this page."]

    alice = User.make(:user => "alice")
    bob = User.make(:user => "bob")
    admin = User.make(:administrator, :user => "admin")

    # Anonymous and another user can't access, owner and admin can
    data = [{:user => nil,   :should_be_denied => true},

            {:user => bob,   :should_be_denied => true},
            {:user => alice, :should_be_denied => false},
            {:user => admin, :should_be_denied => false}]

    data.each do |test|
      log_in_as(test[:user]) if test[:user]
      visit "/users/#{alice.user}"

      has_access_denied_message = page.has_content?(access_denied_messages[0]) || page.has_content?(access_denied_messages[1])
      has_access_denied_message.should == test[:should_be_denied]

      log_out if logged_in?
    end
  end

  scenario "changing password" do
    user = User.make(:password => "oldpass")
    log_in_with(:username => user.user, :password => "oldpass")

    click_link "Change password"

    fill_in 'user_password_old', :with => "oldpass"
    fill_in 'user_password', :with => "newpass"
    fill_in 'user_password_confirmation', :with => "newpass"
    click_button "Change Password"

    page.should have_content "Your password has been updated."

    email = ActionMailer::Base.deliveries.last
    email.subject.should == "ASSDA User Registration - password changed"
    email.encoded.should match(/Your ASSDA password has been updated./)
    email.encoded.should match(/#{user.user}/)

    log_out
    log_in_with(:username => user.user, :password => "newpass")
  end

  scenario "resetting password" do
    user = User.make
    visit "/session/new"
    click_link "Recover your account"

    fill_in :reset_password_email, :with => user.email
    click_button "Reset password"

    page.should have_content "Your username and a new password have been emailed to you."

    email = ActionMailer::Base.deliveries.last
    email.encoded.should match /Username: #{user.user}\r$/
    email.encoded =~ /Password: (.*)\r$/
    new_password = $1

    log_in_with(:username => user.user, :password => new_password)
  end
end
