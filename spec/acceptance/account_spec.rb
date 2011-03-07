require File.dirname(__FILE__) + '/acceptance_helper'

feature "Accounts", %q{
  In order to get access to archived data
  As a user
  I want to log in and manage my account
} do

  scenario "logging in and out" do
    user = User.make
    log_in(user)
    find("#header").should have_content(user.user)

    log_out
  end



  def log_in(user)
    visit "/"
    click_link "Log in"

    fill_in "session_username", :with => user.user
    fill_in "session_password", :with => user.password
    click_button "Log in"

    page.should have_content("Login successful")
  end

  def log_out
    click_link "Log out"
    page.should have_content("You have successfully logged out.")
  end
end
