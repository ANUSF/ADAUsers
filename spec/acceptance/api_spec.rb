require File.dirname(__FILE__) + '/acceptance_helper'

feature "API", %q{
  In order to fetch user information
  As a remote website
  I want to request information via a JSON API
} do

  scenario "fetching user role" do
    user = User.make
    visit "/users/#{user.user}/role"
    page.should have_content "affiliateusers"
  end

  scenario "fetching user details" do
    user = User.make
    visit "/users/#{user.user}/details"
    page.should have_content user.to_json
  end

  scenario "enquiring about user access rights to category A datasets" do
    user = User.make

    accessLevelNoAccess = AccessLevel.make
    accessLevelPending = AccessLevel.make
    accessLevel = AccessLevel.make
    user.permissions_a.create(:datasetID => accessLevelPending.datasetID, :permissionvalue => 0)
    user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)

    visit "/users/#{user.user}/access/#{accessLevelNoAccess.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)
    
    visit "/users/#{user.user}/access/#{accessLevelPending.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit "/users/#{user.user}/access/#{accessLevel.datasetID}"
    page.should have_content({:browse => true, :analyse => true, :download => true}.to_json)
  end

  scenario "enquiring about user access rights to category B datasets" do
    fail "Not yet implemented"
  end

  scenario "accessing the API without permission" do
    # TODO: Perhaps IP address filtering for these actions?
    fail "Not yet implemented"
  end
end
