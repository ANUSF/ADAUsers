require File.dirname(__FILE__) + '/acceptance_helper'

feature "Undertaking forms", %q{
  In order to gain access to datasets
  As a site user
  I want to submit general and resticted undertaking forms
} do

  scenario "submitting a general undertaking form" do
    # Given a non-acspri user and a dataset
    user = User.make(:confirmed_acspri_member => 0)
    log_in_as(user)
    access_level = AccessLevel.make
    
    # When I visit the general undertaking form
    visit "/users/#{user.user}/undertakings/new"
    
    # And I fill out the first page
    select access_level.dataset_description, :from => 'undertaking_dataset_ids'
    check 'undertaking_intended_use_type_government'
    check 'undertaking_intended_use_type_consultancy'
    check 'undertaking_intended_use_type_thesis'
    fill_in 'undertaking_intended_use_other', :with => "Other intended use"
    fill_in 'undertaking_email_supervisor', :with => "supervisor@university.edu.au"
    fill_in 'undertaking_intended_use_description', :with => "World domination or somesuch."
    fill_in 'undertaking_funding_sources', :with => "Numbered Swiss bank account"

    # And I click "Continue", then "I agree"
    click_button "Continue"
    click_button "I agree"

    # Then my undertaking should be recorded
    undertaking = Undertaking.last
    undertaking.user.should == user
    undertaking.datasets.should == [access_level]
    undertaking.intended_use_type.should == [:government, :consultancy, :thesis]
    undertaking.intended_use_other.should == "Other intended use"
    undertaking.email_supervisor.should == "supervisor@university.edu.au"
    undertaking.intended_use_description.should == "World domination or somesuch."
    undertaking.funding_sources.should == "Numbered Swiss bank account"
    undertaking.agreed.should be_true

    # And I should have ACSPRI status "requested"
    user.reload
    user.acsprimember.should == User::ACSPRI_REQUESTED # 2

    # And I should have the pending datasets that I requested
    user.permissions_a.count.should == 1
    user.permissions_a.first.datasetID.should == access_level.datasetID
    
    # And some emails should have been sent - to myself and to an admin
    fail "Write email tests"
  end

  scenario "declining a general undertaking form" do
    
  end

  scenario "submitting a restricted undertaking form" do
    
  end

  scenario "declining a restricted undertaking form" do
    
  end

  scenario "undertaking forms are only accessible by registered users" do
    
  end

  # TODO: Admin tests
  #       We already cover granting ACSPRI membership and access to pending datasets.
  #       What would be useful is an overview (a queue?) of who has requested access.
end
