require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Edit basic attributes", %q{
  In order to manage user access to data
  As an administrator
  I want to view and adjust basic user details
} do

  before(:each) do
    @user = User.make(:user => 'tester')
  end


  scenario "viewing user details page" do
    visit "/users/tester/edit"

    # -- User details
    page.should have_content("Username")
    page.should have_content("tester")

    page.should have_content("Email address")
    page.should have_content(@user.email)
    
    page.should have_content("ACSPRI member?")
    page.should have_content(@user.acsprimember ? "Yes" : "No")
    
    page.should have_content("Role")
    page.should have_content(@user.user_roles.first.roleID)
  end


  scenario "changing ACSPRI membership" do
    visit "/users/tester/edit"

    find("tr#acspri").should have_content("Yes")
    find("tr#acspri").click_button("Change")
    find("tr#acspri").should have_content("No")
  end


  scenario "changing role" do
    visit "/users/tester/edit"
    find("select#user_user_role option[selected='selected']").should have_content("affiliateusers")

    find("select#user_user_role").select("administrator")
    find("tr#role").click_button("Change")

    find("select#user_user_role option[selected='selected']").should have_content("administrator")
  end
end
