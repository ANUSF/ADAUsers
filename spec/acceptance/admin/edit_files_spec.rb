require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Modify access to dataset files", %q{
  In order to manage user access to data
  As an administrator
  I want to adjust permissions for dataset files
} do

  before(:each) do
    AccessLevel.destroy_all

    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end


  scenario "Update File Access button is not visible when there are no files" do
    [:a, :b].each do |category|
      # Given that I have an accessible dataset with no files
      accessLevel = AccessLevel.make(category)
      @user.permissions(category).create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
      
      # When I view the page
      visit "/admin/users/tester/edit"
      
      # Then I should not see the "Update File Access" button
      page.should_not have_selector("input[type='submit'][value='Update File Access']")
    end
  end


  scenario "granting access to a file" do
    [:a, :b].each do |category|
      # Given that I have an accessible dataset with a file, but no access to the file
      accessLevel = AccessLevel.make(category)
      accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID, :accessLevel => category.to_s.upcase)
      @user.permissions(category).create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)

      # When I view the page, the "Grant Download" checkbox should not be checked
      visit "/admin/users/tester/edit"
      page.should_not have_selector("#category_#{category} table#accessible input#file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}[checked]")

      # When I check "Grant Download" and press "Update File Access"
      page.check("file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}")
      find("#category_#{category}").click_button("Update File Access")

      # Then I should have access to the file, and the "Grant Download" checkbox should be checked
      permission_value = (category == :a ? 1 : 2)
      @user.permissions(category).where(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => permission_value).should be_present
      page.should have_selector("#category_#{category} table#accessible input#file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}[checked]")
    end
  end


  scenario "revoking access to a file" do
    [:a, :b].each do |category|
      permission_value = (category == :a ? 1 : 2)

      # Given that I have an accessible dataset with a file, and with access to the file
      accessLevel = AccessLevel.make(category)
      accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID, :accessLevel => category.to_s.upcase)
      @user.permissions(category).create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
      @user.permissions(category).create(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => permission_value)

      # When I view the page, the "Grant Download" checkbox should be checked
      visit "/admin/users/tester/edit"
      page.should have_selector("#category_#{category} table#accessible input#file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}[checked]")

      # When I uncheck "Grant Download" and press "Update File Access"
      page.uncheck("file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}")
      find("#category_#{category}").click_button("Update File Access")

      # Then I should not have access to the file, and the "Grant Download" checkbox should be unchecked
      @user.permissions(category).where(:datasetID => accessLevelFile.datasetID, :fileID => accessLevelFile.fileID, :permissionvalue => permission_value).should_not be_present
      page.should_not have_selector("#category_#{category} table#accessible input#file_#{ddi_to_id(accessLevelFile.datasetID)}_#{accessLevelFile.fileID}[checked]")
    end
  end
end
