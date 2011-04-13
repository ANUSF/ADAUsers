require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Administer undertakings", %q{
  In order to approve user access to datasets
  As an administrator
  I want to view and manage undertaking form submissions
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end

  after(:all) do
    log_out if logged_in?
  end


  scenario "view undertakings and details" do
    # Given a user with a general and restricted undertaking
    undertakings = [@user.undertakings.make(:is_restricted => false), @user.undertakings.make(:is_restricted => true)]

    # When I visit the admin undertakings page
    visit "/admin/undertakings"

    # Then I should see both undertakings and their details
    ["Username", "Type", "Submitted"].each { |header| page.should have_selector("th", :text => header) }
    undertakings.each do |undertaking|
      # Basic info
      page.should have_selector("td", :text => undertaking.user.user)
      page.should have_selector("td", :text => undertaking.is_restricted ? "Restricted" : "General")
      page.should have_selector("td", :text => "less than a minute ago ("+Time.now.utc.strftime("%d-%m-%Y")+")")

      # Datasets
      undertaking.datasets.each { |dataset| page.should have_selector("li", :text => dataset.dataset_description) }

      # Intended use
      undertaking.intended_use_type.each do |iut|
        page.should have_selector("li", :text => Undertaking.intended_use_options[iut.to_sym])
      end
      page.should have_selector("li", :text => "Other: #{undertaking.intended_use_other}")
      page.should have_content(undertaking.intended_use_description)
      page.should have_content(undertaking.email_supervisor)

      # Funding
      page.should have_content(undertaking.funding_sources)

      # Action buttons
      page.should have_selector("a", :text => "Process request")
      page.should have_selector("a", :text => "Mark as complete")
    end
  end


  scenario "marking an undertaking as complete" do
    
  end


  scenario "reopening a completed undertaking" do
    
  end
end
