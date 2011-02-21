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
    # Make some datasets
    ['A', 'G', 'B', 'S'].each do |accessLevel|
      5.times { AccessLevel.make(:accessLevel => accessLevel) }
    end

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
    
    accessLevelPresent = AccessLevel.make
    accessLevelAbsent = AccessLevel.make
    @user.permissions_a.create(:datasetID => accessLevelPresent.datasetID, :permissionvalue => 1)

    @user.permissions_a.where(:datasetID => accessLevelPresent.datasetID).should_not be_empty
    @user.permissions_a.where(:datasetID => accessLevelAbsent.datasetID).should be_empty

    visit "/users/tester/edit"
    
    # Submit the form with these two datasets
    find("select#user_datasets_cat_a_to_add").select(accessLevelPresent.dataset_description)
    find("select#user_datasets_cat_a_to_add").select(accessLevelAbsent.dataset_description)
    find("#category_a").click_button("Add dataset(s)")

    # Ensure that both are now present, and without any duplicate rows
    @user.permissions_a.where(:datasetID => accessLevelPresent.datasetID).count.should == 1
    @user.permissions_a.where(:datasetID => accessLevelAbsent.datasetID).count.should == 1
  end


  scenario "viewing added category A datasets" do
    # Start with two datasets - one that's already been added, and one that hasn't
    accessLevels = {}
    accessLevels[:present] = AccessLevel.make
    accessLevels[:pending] = AccessLevel.make
    accessLevels[:absent] = AccessLevel.make

    @user.permissions_a.create(:datasetID => accessLevels[:present].datasetID, :permissionvalue => 1)
    @user.permissions_a.create(:datasetID => accessLevels[:pending].datasetID, :permissionvalue => 0)

    @user.permissions_a.where(:datasetID => accessLevels[:present].datasetID).should_not be_empty
    @user.permissions_a.where(:datasetID => accessLevels[:pending].datasetID).should_not be_empty
    @user.permissions_a.where(:datasetID => accessLevels[:absent].datasetID).should be_empty

    visit "/users/tester/edit"

    # dataset => table_name => should_be_present
    # eg. present => pending => false
    expected_results = {:present => {:accessible => true, :pending => false},
                        :pending => {:accessible => false, :pending => true},
                        :absent =>  {:accessible => false, :pending => false}}

    expected_results.each_pair do |dataset, expected_tables|
      expected_tables.each_pair do |table, should_be_present|
        find("#category_a table##{table}").has_content?(accessLevels[dataset].datasetID).should == should_be_present
        find("#category_a table##{table}").has_content?(accessLevels[dataset].datasetname).should == should_be_present
      end
    end
  end


  scenario "deleting an accessible or pending dataset" do
    accessLevels = {}
    accessLevels[:accessible] = AccessLevel.make
    accessLevels[:pending] = AccessLevel.make

    @user.permissions_a.create(:datasetID => accessLevels[:accessible].datasetID, :permissionvalue => 1)
    @user.permissions_a.create(:datasetID => accessLevels[:pending].datasetID, :permissionvalue => 0)

    @user.permissions_a.where(:datasetID => accessLevels[:accessible].datasetID).should_not be_empty
    @user.permissions_a.where(:datasetID => accessLevels[:pending].datasetID).should_not be_empty

    # When I go to the user edit page
    # Then I should see the accessible dataset in the table
    # When I click on the image link for removing the accessible dataset
    # Then I should not see the accessible dataset in the table

    accessLevels.each_pair do |dataset, accessLevel|
      visit "/users/tester/edit"
      find("#category_a table##{dataset}").should have_content(accessLevels[dataset].datasetID)
      find("#category_a table##{dataset} a:has(img[alt='delete'])").click()
      page.should_not have_selector("#category_a table##{dataset}")
    end
  end


  scenario "adding access to a pending dataset" do
#    # TODO: This needs adjustment - the existing interface uses a form for the whole table
#    #       with checkboxes for each row, instead of a linked action for each row.
#
#    # Given that I have a pending dataset
#    accessLevel = AccessLevel.cat_a[0]
#    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 0)
#
#    # And I can see it in the pending table, but not the accessible table
#    visit "/users/tester/edit"
#    find("#category_a table#pending").should        have_content(accessLevel.datasetID)
#    find("#category_a table#accessible").should_not have_content(accessLevel.datasetID)
#
#    # When I click on the image link "add"
#    find("#category_a table#pending a:has(img[alt='add'])").click()
#
#    # Then I should not see the dataset in the pending table, but I should see it in the accessible table
#    find("#category_a table#pending").should_not have_content(accessLevel.datasetID)
#    find("#category_a table#accessible").should  have_content(accessLevel.datasetID)
  end


  scenario "revoking permission to an accessible dataset" do
    # Given that I have an accessible dataset with a file
    accessLevel = AccessLevel.make
    accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1, :fileID => accessLevelFile.fileID)

    # And I can see it in the accessible table, but not the pending table
    visit "/users/tester/edit"
    find("#category_a table#accessible").should have_content(accessLevel.datasetID)
    page.should_not have_selector("#category_a table#pending")

    # And I can see the file details in the table
    ['File Content', 'File ID', 'Access Level', 'Grant Download'].each do |column_name|
      find("#category_a table#accessible").should have_content(column_name)
    end

    # When I click on the image link "revoke"
    find("#category_a table#accessible a:has(img[alt='revoke'])").click()

    # Then I should not have permission to access the dataset, but I should do for the file
    @user.permissions_a.where(:datasetID => accessLevel.datasetID, :fileID => nil).should be_empty
    @user.permissions_a.where(:datasetID => accessLevel.datasetID, :fileID => accessLevelFile.fileID).should_not be_empty

    # And I should see the dataset in the table without the revoke button
    find("#category_a table#accessible").should have_content(accessLevel.datasetID)
    page.should_not have_selector("#category_a table#accessible img[alt='revoke']")

    # And I should see the file details in the table
    ['File Content', 'File ID', 'Access Level', 'Grant Download'].each do |column_name|
      find("#category_a table#accessible").should have_content(column_name)
    end
  end
end
