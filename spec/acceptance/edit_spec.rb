require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit", %q{
  In order to administer user access to data
  As an administrator
  I want to adjust user permissions
} do

  scenario "viewing user details page" do
    user = User.make(:user => 'tester')
    
    visit "/user/tester/edit"

    # -- User details
    page.should have_content("Username")
    page.should have_content("tester")

    page.should have_content("Email address")
    page.should have_content(user.email)
    
    page.should have_content("ACSPRI member?")
    page.should have_content(user.acsprimember ? "Yes" : "No")
    
    page.should have_content("Role")
    page.should have_content(user.user_roles.first.roleID)
  end
end
