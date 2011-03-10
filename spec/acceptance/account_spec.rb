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

    visit "/"
    page.should have_selector("a", :text => "Log in")

    log_in_as(user)
    find("#header").should have_content(user.user)
  end

  scenario "viewing user details" do
    user = User.make
    log_in_as(user)
    visit "/users/#{user.user}"

    page.should have_content(user.name)
  end

  scenario "viewing another user's details" do
    access_denied_messages = ["You may not view another user's details.", "You must be logged in to access this page."]

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
end
