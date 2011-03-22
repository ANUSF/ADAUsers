require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Edit basic attributes", %q{
  In order to manage user access to data
  As an administrator
  I want to view and adjust basic user details
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end

  scenario "viewing user details page" do
    visit "/admin/users/tester/edit"

    # -- User details
    page.should have_content("Name")
    page.should have_content([@user.title, @user.fname, @user.sname].join(' '))

    page.should have_content("Username")
    page.should have_content("tester")

    page.should have_content("Email address")
    page.should have_content(@user.email)
    
    page.should have_content("Affiliation")
    page.should have_content(@user.australian_uni.Longuniname)

    page.should have_content("Type of work")
    page.should have_content(User.new.action_options[0][1])

    page.should have_content("Member for")
    #page.should have_content("about 1 hour")

    page.should have_content("Last access")
    page.should have_content("Never")

    page.should have_content("Number of accesses")
    page.should have_content("(last 12 months / all time)")
    page.should have_content("0 / 0")

    page.should have_content("ACSPRI member?")
    page.should have_content(@user.acsprimember ? "Yes" : "No")
    
    page.should have_content("Role")
    page.should have_content(@user.user_roles.first.roleID)
  end


  scenario "changing ACSPRI membership" do
    @user.acsprimember = 2
    @user.save!

    visit "/admin/users/tester/edit"

    find("tr#acspri").should have_content("Requested")
    find("tr#acspri").click_button("Grant membership")
    find("tr#acspri").should have_content("Yes")
    find("tr#acspri").click_button("Revoke membership")
    find("tr#acspri").should have_content("No")
  end


  scenario "changing role" do
    visit "/admin/users/tester/edit"
    find("select#user_user_role option[selected='selected']").should have_content("affiliateusers")

    find("select#user_user_role").select("administrator")
    find("tr#role").click_button("Change")

    find("select#user_user_role option[selected='selected']").should have_content("administrator")
  end


  scenario "accessing the edit page without permission" do
    log_out

    [nil, @user].each do |user|
      log_in_as(user) if user
      visit "/admin/users/#{@user.user}/edit"
      page.should have_content("You must be an administrator or publisher to access this page.")
      should_be_on("/")
      log_out if logged_in?
    end
  end
end
