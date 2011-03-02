require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Modify access to pending datasets", %q{
  In order to manage user access to data
  As an administrator
  I want to adjust permissions for pending datasets
} do

  before(:each) do
    @user = User.make(:user => 'tester')
  end


  scenario "Add Access button does not appear when there are no pending datasets" do
    # Given that I have an accessible dataset, but no pending datasets
    accessLevelA = AccessLevel.make(:a)
    accessLevelB = AccessLevel.make(:b)
    @user.permissions_a.create(:datasetID => accessLevelA.datasetID, :permissionvalue => 1)
    @user.permissions_b.create(:datasetID => accessLevelB.datasetID, :permissionvalue => 1)

    # When I view the page
    visit "/users/tester/edit"

    # Then I should not see the button "Add Access"
    page.should_not have_selector("input[type='submit'][value='Add Access']")
  end


  scenario "adding access to a pending dataset" do
    [:a, :b].each do |category|
      # Given that I have two pending datasets
      accessLevels = [AccessLevel.make(category), AccessLevel.make(category)]
      accessLevels.each { |accessLevel| @user.permissions(category).create(:datasetID => accessLevel.datasetID, :permissionvalue => 0) }

      # And I can see them in the pending table, but not the accessible table
      visit "/users/tester/edit"
      accessLevels.each { |accessLevel| find("#category_#{category} table#pending").should have_content(accessLevel.datasetID) }
      page.should_not have_selector("#category_#{category} table#accessible")
      
      # When I check the checkbox next to the first dataset, and I press "Add Access"
      find("#category_#{category} table#pending").check("pending_#{ddi_to_id(accessLevels[0].datasetID)}")
      find("#category_#{category}").click_button("Add Access")
      
      # Then I should not see the first dataset in the pending table, but I should see it in the accessible table
      find("#category_#{category} table#pending").should_not have_content(accessLevels[0].datasetID)
      find("#category_#{category} table#accessible").should  have_content(accessLevels[0].datasetID)
      
      # And I should see the second dataset in the pending table, but I should not see it in the accessible table
      find("#category_#{category} table#pending").should        have_content(accessLevels[1].datasetID)
      find("#category_#{category} table#accessible").should_not have_content(accessLevels[1].datasetID)
    end
  end
end
