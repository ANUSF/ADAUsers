require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Modify access to cat A dataset files", %q{
  In order to manage user access to data
  As an administrator
  I want to adjust permissions wrt. category A dataset files
} do

  before(:each) do
    @user = User.make(:user => 'tester')
  end


  scenario "Update File Access button is not visible when there are no files" do
    # Given that I have an accessible dataset with no files
    accessLevel = AccessLevel.make
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
    
    # When I view the page
    visit "/users/tester/edit"

    # Then I should not see the "Update File Access" button
    page.should_not have_selector("input[type='submit'][value='Update File Access']")
  end


  scenario "granting access to a file" do
    # Given that I have an accessible dataset with a file, but no access to the file
    accessLevel = AccessLevel.make
    accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)

    # When I view the page, the "Grant Download" checkbox should not be checked
    visit "/users/tester/edit"
    page.should_not have_selector("#category_a table#accessible input#file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}[checked]")

    # When I check "Grant Download" and press "Update File Access"
    page.check("file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}")
    page.click_button("Update File Access")

    # Then I should have access to the file, and the "Grant Download" checkbox should be checked
    @user.permissions_a.where(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => 1).should be_present
    page.should have_selector("#category_a table#accessible input#file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}[checked]")
  end


  scenario "revoking access to a file" do
    # Given that I have an accessible dataset with a file, and with access to the file
    accessLevel = AccessLevel.make
    accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
    @user.permissions_a.create(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => 1)

    # When I view the page, the "Grant Download" checkbox should be checked
    visit "/users/tester/edit"
    page.should have_selector("#category_a table#accessible input#file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}[checked]")

    # When I uncheck "Grant Download" and press "Update File Access"
    page.uncheck("file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}")
    page.click_button("Update File Access")

    # Then I should not have access to the file, and the "Grant Download" checkbox should be unchecked
    @user.permissions_a.where(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => 1).should_not be_present
    page.should_not have_selector("#category_a table#accessible input#file_#{ddi_to_id(accessLevel.datasetID)}_#{accessLevelFile.fileID}[checked]")
  end
end
