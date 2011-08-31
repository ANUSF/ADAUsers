require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Administer undertakings", %q{
  In order to approve user access to datasets
  As an administrator
  I want to view and manage undertaking form submissions
} do

  before(:each) do
    Undertaking.destroy_all
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end

  after(:all) do
    log_out if logged_in?
  end


  scenario "view undertakings and details" do
    # Given a user with a general and restricted undertaking
    undertakings = [@user.undertakings.make(:agreed => true, :is_restricted => false),
                    @user.undertakings.make(:agreed => true, :is_restricted => true)]

    # When I visit the admin undertakings page
    visit "/admin/undertakings"

    # Then I should see the number of unprocessed undertakings
    page.should have_selector(".admin-undertakings-stats", :text => "2 unprocessed access requests")

    # And I should see both undertakings and their details
    ["Username", "Type", "Submitted", "Processed"].each { |header| page.should have_selector("th", :text => header) }
    undertakings.each do |undertaking|
      # Basic info
      page.should have_selector("td", :text => undertaking.user.user)
      page.should have_selector("td", :text => undertaking.is_restricted ? "Restricted" : "General")
      page.should have_selector("td", :text => "less than a minute ago ("+Time.now.utc.strftime("%d-%m-%Y")+")")
      page.should have_selector("td", :text => undertaking.processed ? "Yes" : "No")

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
    # Given a user and an undertaking
    undertaking = @user.undertakings.make(:agreed => true)

    # When I go to the admin page and mark the undertaking as complete
    visit "/admin/undertakings"
    click_link "Mark as complete"

    # Then the undertaking should be marked as complete
    page.should have_content("That undertaking has been marked as complete.")
    visit "/admin/undertakings?show_processed_requests=1"
    page.should have_selector("tr.admin-undertaking-summary td", :text => "Yes")
    page.should have_selector(".admin-undertaking-actions a", :text => "Reopen")
  end


  scenario "reopening a completed undertaking" do
    # Given a user and a processed undertaking
    undertaking = @user.undertakings.make(:agreed => true, :processed => true)

    # When I go to the admin page and reopen the undertaking
    visit "/admin/undertakings?show_processed_requests=1"
    click_link "Reopen"

    # Then the undertaking should be reopened
    page.should have_content("That undertaking has been reopened.")
    page.should have_selector("tr.admin-undertaking-summary td", :text => "No")
    page.should have_selector(".admin-undertaking-actions a", :text => "Mark as complete")
  end
end
