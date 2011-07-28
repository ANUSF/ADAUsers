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

  after(:all) do
    log_out if logged_in?
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
    page.should have_content("#{@user.australian_uni.Longuniname} (#{@user.country.Countryname})")

    page.should have_content("Type of work")
    page.should have_content(User.new.action_options[0][1])

    page.should have_content("Member since")
    #page.should have_content("about 1 hour")

    page.should have_content("Last access")
    page.should have_content("Never")

    page.should have_content("Number of accesses")
    page.should have_content("(last 12 months / all time)")
    page.should have_content("0 / 0")

    page.should have_content("Position")
    page.should have_content(@user.position_s)

    page.should have_content("Signed undertaking form?")
    page.should have_content(@user.signed_undertaking_form? ? "Yes" : "No")
    
    page.should have_content("Nesstar role")
    page.should have_content(@user.user_roles.first.roleID)

    page.should have_content("CMS role")
    page.should have_content(@user.role_cms)
  end


  scenario "changing undertaking form signed-ness" do
    @user.signed_undertaking_form = User::UNDERTAKING_REQUESTED
    @user.save!

    visit "/admin/users/tester/edit"

    find("tr#signed_undertaking_form").should have_content("Requested")
    find("tr#signed_undertaking_form").click_button("Mark form as signed")
    find("tr#signed_undertaking_form").should have_content("Yes")
    find("tr#signed_undertaking_form").click_button("Mark form as unsigned")
    find("tr#signed_undertaking_form").should have_content("No")
  end


  scenario "changing nesstar role" do
    visit "/admin/users/tester/edit"
    find("select#user_user_role option[selected='selected']").should have_content("affiliateusers")
    @user.user_ejb.admin.should == 0

    # Change to administrator
    find("select#user_user_role").select("administrator")
    find("tr#role").click_button("Change")

    find("select#user_user_role option[selected='selected']").should have_content("administrator")
    @user.user_ejb.reload.admin.should == 1

    # Change back to affiliateuser
    find("select#user_user_role").select("affiliateusers")
    find("tr#role").click_button("Change")

    find("select#user_user_role option[selected='selected']").should have_content("affiliateusers")
    @user.user_ejb.reload.admin.should == 0
  end


  scenario "changing CMS role" do
    visit "/admin/users/tester/edit"
    find("select#user_role_cms option[selected='selected']").should have_content("member")

    # Change to administrator
    find("select#user_role_cms").select("administrator")
    find("tr#role-cms").click_button("Change")

    find("select#user_role_cms option[selected='selected']").should have_content("administrator")

    # Change back to member
    find("select#user_role_cms").select("member")
    find("tr#role-cms").click_button("Change")

    find("select#user_role_cms option[selected='selected']").should have_content("member")
  end


  scenario "changing password via edit user page" do
    [:edit_user, :edit_user_details].each do |page_name|
      visit "/admin/users/tester/edit"
      click_link "Edit user details" if page_name == :edit_user_details
      click_link "Change user password"

      page.should have_content "Changing #{@user.user}'s password. #{@user.user.capitalize} will be informed via email of this password change."
      fill_in 'user_password', :with => "newpass"
      fill_in 'user_password_confirmation', :with => "newpass"
      click_button "Change Password"

      page.should have_content "Tester's password has been updated."

      log_out
      log_in_with(:username => @user.user, :password => "newpass")

      # Return to admin account
      log_out
      log_in_as(@admin)
    end
  end


  scenario "accessing the edit page without permission" do
    log_out

    [nil, @user].each do |user|
      log_in_as(user) if user
      visit "/admin/users/#{@user.user}/edit"
      page.should have_content("You must be an administrator or publisher to access this page.")
      current_path.should == "/"
      log_out if logged_in?
    end
  end
end
