require File.dirname(__FILE__) + '/acceptance_helper'

feature "Accounts", %q{
  In order to get access to archived data
  As a user
  I want to log in and manage my account
} do

  scenario "logging in and out" do
    user = User.make

    visit "/"
    page.should have_selector("a", :text => "Log in")

    log_in_as(user)
    find("#header").should have_content(user.user)

    log_out
  end
end
