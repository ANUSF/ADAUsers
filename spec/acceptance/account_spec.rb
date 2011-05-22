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
    current_path.should == "/users/#{user.user}"
    find("header").should have_content(user.user)
  end

  scenario "logging in with redirect link" do
    user = User.make

    visit "/session/new?redirect_to=#{new_user_undertaking_path(user)}"

    fill_in "session_username", :with => user.user
    fill_in "session_password", :with => user.user
    click_button "Log in"

    page.should have_content("Login successful")
    page.should have_content("Apply for access to download")
    current_path.should == new_user_undertaking_path(user)
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
    # Given a user
    user = User.make
    visit "/session/new"
    click_link "Recover your account"

    # When I click the reset password link,
    # an email should be sent to me containing reset instructions
    fill_in :reset_password_email, :with => user.email
    click_button "Reset password"
    page.should have_content "An email has been sent to you containing instructions to reset your password."

    email = ActionMailer::Base.deliveries.last
    email.encoded.should match(/password reset for this account/)

    # When I fetch the link from the email and visit that page,
    # Then I should see a change password form.
    email.encoded =~ /^http:\/\/[^\/]+(.*)$/
    visit $1
    page.should have_selector("h2", :text => "Reset your password")

    # When I fill it out and submit it
    fill_in 'user_password', :with => "newpass"
    fill_in 'user_password_confirmation', :with => "newpass"
    click_button "Change Password"

    # Then my password should be changed,
    # and I should be able to log in with the new password
    page.should have_content "Your password has been updated."
    log_out
    log_in_with(:username => user.user, :password => "newpass")
  end

  scenario "attempting to access the password reset page with a bogus token" do
    visit "/users/reset_password?token=abc123"
    page.should have_content "That reset password link is invalid. Please make sure that the URL you entered is correct."
  end

  scenario "attempting a password change using a bogus token" do
    bogus_token = "abc123"
    password = "asdf4321"
    user = User.make

    tests = [{:user => nil,       :response => "You must be logged in to access this page."},
             {:user => User.make, :response => "You may not access another user's details."}]

    tests.each do |test|
      log_in_as test[:user] if test[:user]

      page.driver.post("/users/#{user.user}", {"user" => {"token_reset_password_confirmation" => bogus_token, "password" => password, "password_confirmation" => password}, "commit"=>"Change Password", "id" => user.user, "_method" => "put"})
      click_link "redirected"

      page.should have_content test[:response]
    end

    log_out
  end

  scenario "resetting password on unknown email address" do
    visit "/session/new"
    click_link "Recover your account"

    fill_in :reset_password_email, :with => "ajskdljfkl@jdklfjs.com"
    click_button "Reset password"

    page.should have_content "That email address was not found."
  end
end
