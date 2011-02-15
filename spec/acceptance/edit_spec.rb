require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit", %q{
  In order to administer user access to data
  As an administrator
  I want to adjust user permissions
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

  scenario "viewing available category A datasets" do
    visit "/users/tester/edit"
    
    # Here's the query from the old PHP system:
    #select datasetID, datasetname, fileContent from accesslevel al1 where al1.accessLevel in ('A', 'G') and al1.fileID is null and al1.datasetID not in (select datasetID from accesslevel al2 where al2.accessLevel in ('B', 'S') and al2.fileID is null) ORDER BY al1.datasetID ASC
    # The query below generates equivalent (though not identical) SQL.

    accessLevels = AccessLevel.where(:accessLevel => ['A', 'G'], :fileID => nil).where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)").order('datasetID ASC')

    # Test that the first, middle and last item are present
    accessLevelsToTest = [accessLevels.first, accessLevels[accessLevels.count/2], accessLevels.last]

    accessLevelsToTest.each do |accessLevel|
      find("select#user_datasets_cat_a_to_add").should have_content(accessLevel.dataset_description)
    end
  end

  scenario "adding a category A dataset" do
    # Start with two datasets - one that's already been added, and one that hasn't
    accessLevelPresent = AccessLevel.cat_a.first
    accessLevelAbsent = AccessLevel.cat_a.last
    @user.permissions_a.make(:datasetID => accessLevelPresent.datasetID)

    @user.permissions_a.where(:datasetID => accessLevelPresent.datasetID).should_not be_empty
    @user.permissions_a.where(:datasetID => accessLevelAbsent.datasetID).should be_empty

    visit "/users/tester/edit"
    
    # Submit the form with these two datasets
    find("select#user_datasets_cat_a_to_add").select(accessLevelPresent.dataset_description)
    find("select#user_datasets_cat_a_to_add").select(accessLevelAbsent.dataset_description)
    find("#category_a").click_button("Add dataset")

    # Ensure that both are now present, and without any duplicate rows
    @user.permissions_a.where(:datasetID => accessLevelPresent.datasetID).count.should == 1
    @user.permissions_a.where(:datasetID => accessLevelAbsent.datasetID).count.should == 1
  end
end
