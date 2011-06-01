require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Modify access to pending datasets", %q{
  In order to manage user access to data
  As an administrator
  I want to adjust permissions for pending datasets
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end


  scenario "Add Access button does not appear when there are no pending datasets" do
    # Given that I have an accessible dataset, but no pending datasets
    accessLevelA = AccessLevel.make(:a)
    accessLevelB = AccessLevel.make(:b)
    @user.permissions_a.create(:datasetID => accessLevelA.datasetID, :permissionvalue => 1)
    @user.permissions_b.create(:datasetID => accessLevelB.datasetID, :permissionvalue => 1)

    # When I view the page
    visit "/admin/users/tester/edit"

    # Then I should not see the button "Add Access"
    page.should_not have_selector("input[type='submit'][value='Add Access']")
  end


  scenario "adding access to a pending dataset" do
    # Given a template for the email
    Template.make(:study_access_approval)

    [:a, :b].each do |category|
      # Given that I have two pending datasets
      accessLevels = [AccessLevel.make(category), AccessLevel.make(category)]
      accessLevels.each { |accessLevel| @user.permissions(category).create(:datasetID => accessLevel.datasetID, :permissionvalue => 0) }

      # And I can see them in the pending table, but not the accessible table
      visit "/admin/users/tester/edit"
      accessLevels.each { |accessLevel| find("#category_#{category} table#pending").should have_content(accessLevel.datasetID) }
      page.should_not have_selector("#category_#{category} table#accessible")
      
      # When I check the checkbox next to the first dataset, and I press "Add Access"
      find("#category_#{category} table#pending").check("pending_#{ddi_to_id(accessLevels[0].datasetID)}")
      find("#category_#{category}").click_button("Add Access")
      
      # Then I should be on the email page, and I should see the template for this email
      page.should have_content "Update successful. You may review and edit the confirmation email below before you send it."
      page.should have_selector("#email_from[value='ASSDA <assda@anu.edu.au>']")
      page.should have_selector("#email_to[value='#{@user.email}']")
      page.should have_selector("#email_subject[value='Access approved for #{category == :a ? "general" : "restricted"} dataset(s)']")
      page.should have_selector("#email_body", :text => /You have now been granted access to the following dataset\(s\):/)
      page.should have_selector("#email_body", :text => /#{accessLevels[0].dataset_description}/)

      # When I submit the form
      click_button "Send"

      # Then I should not see the first dataset in the pending table, but I should see it in the accessible table
      find("#category_#{category} table#pending").should_not have_content(accessLevels[0].datasetID)
      find("#category_#{category} table#accessible").should  have_content(accessLevels[0].datasetID)
      
      # And I should see the second dataset in the pending table, but I should not see it in the accessible table
      find("#category_#{category} table#pending").should        have_content(accessLevels[1].datasetID)
      find("#category_#{category} table#accessible").should_not have_content(accessLevels[1].datasetID)

      # And the user should have received an email specifying the datasets that they have gained access to
      email = ActionMailer::Base.deliveries.last
      email.subject.should == "Access approved for #{category == :a ? "general" : "restricted"} dataset(s)"
      email.encoded.should match(/You have now been granted access to the following dataset\(s\):/)
      email.encoded.should match(/#{accessLevels[0].dataset_description}/)
    end
  end
end
