require File.dirname(__FILE__) + '/acceptance_helper'

feature "Undertaking forms", %q{
  In order to gain access to datasets
  As a site user
  I want to submit general and resticted undertaking forms
} do

  after(:each) do
    log_out if logged_in?
  end


  scenario "submitting a general undertaking form" do
    # Given a dataset
    access_level = AccessLevel.make

    [false, true].each do |institution_is_acspri_member|
      # And a user
      name = institution_is_acspri_member ? nil : :foreign
      user = User.make(name, :confirmed_acspri_member => 0)
      user.institution_is_acspri_member.should == institution_is_acspri_member
      log_in_as(user)

      # When I visit the general undertaking form
      visit "/users/#{user.user}/undertakings/new"
      page.should have_content "You will be charged $1,000 per dataset" unless institution_is_acspri_member

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
      undertaking.is_restricted.should be_false
      undertaking.datasets.count.should == 1
      undertaking.datasets.first.datasetID.should == access_level.datasetID
      undertaking.intended_use_type.should == ["government", "consultancy", "thesis"]
      undertaking.intended_use_other.should == "Other intended use"
      undertaking.email_supervisor.should == "supervisor@university.edu.au"
      undertaking.intended_use_description.should == "World domination or somesuch."
      undertaking.funding_sources.should == "Numbered Swiss bank account"
      undertaking.agreed.should be_true

      # And I should have the correct ACSPRI status
      # TODO: Test user that is already ACSPRI keeps it
      user.reload
      user.acsprimember.should == User::ACSPRI_REQUESTED

      # And I should have the pending datasets that I requested
      user.permissions_a.count.should == 1
      user.permissions_a.first.datasetID.should == access_level.datasetID

      # And some emails should have been sent - to myself and to an admin
      emails = ActionMailer::Base.deliveries[-2..-1]
      email_admin = emails.select {|e| e.subject =~ /General Undertaking form signed by/}.first
      email_user = emails.select {|e| e.subject =~ /ASSDA General Undertaking/}.first
      email_admin.should_not be_nil
      email_user.should_not be_nil

      email_admin.encoded.should match(/General Undertaking form \(#{"Non-" unless institution_is_acspri_member}ACSPRI\) signed by #{undertaking.user.user}/)
      email_admin.encoded.should match(/#{access_level.dataset_description}/)

      email_user.encoded.should match(/invoiced/) unless institution_is_acspri_member
      email_user.encoded.should match(/Please keep this email as a copy of the agreement:/)
      email_user.encoded.should match(/#{access_level.dataset_description}/)

      log_out
    end
  end

  scenario "declining a general undertaking form" do
    # Given a user and an unaccepted undertaking
    user = User.make
    undertaking = Undertaking.make(:user => user)
    log_in_as user

    # When I view the undertaking and do not agree with it
    visit "/users/#{user.user}/undertakings/#{undertaking.id}/edit"
    click_button "I do not agree"

    # Then the undertaking should be deleted
    Undertaking.where(:id => undertaking.id).count.should == 0

    # And I should be on my profile page
    current_path.should == "/users/#{user.user}"
  end

  scenario "submitting a restricted undertaking form" do
    
  end

  scenario "declining a restricted undertaking form" do
    
  end

  scenario "undertaking forms are only accessible by registered users" do
    user = User.make

    logged_in?.should be_false
    visit "/users/#{user.user}/undertakings/new"

    page.should have_content "You must be logged in to access this page."
    current_path.should == "/login"
  end

  scenario "user cannot access another user's undertaking form" do
    alice = User.make
    undertaking = Undertaking.make(:user => alice)

    eve = User.make
    log_in_as eve

    visit "/users/#{alice.user}/undertakings/#{undertaking.id}/edit"
    page.should have_content "You may not access another user's details."
    current_path.should == "/"
  end

  # TODO: Admin tests
  #       We already cover granting ACSPRI membership and access to pending datasets.
  #       What would be useful is an overview (a queue?) of who has requested access.
end
