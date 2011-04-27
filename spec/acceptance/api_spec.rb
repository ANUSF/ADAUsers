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
    user = User.make

    accessLevelNoAccess = AccessLevel.make(:b)
    accessLevelPending = AccessLevel.make(:b)
    accessLevelBrowse = AccessLevel.make(:b)
    accessLevelAnalyse = AccessLevel.make(:b)
    accessLevelDownload = AccessLevel.make(:b)
    accessLevelAnalyseDownload = AccessLevel.make(:b)

    user.permissions_b.create(:datasetID => accessLevelPending.datasetID, :permissionvalue => 0)
    user.permissions_b.create(:datasetID => accessLevelBrowse.datasetID, :permissionvalue => 1)
    user.permissions_b.create(:datasetID => accessLevelAnalyse.datasetID, :permissionvalue => 3)
    user.permissions_b.create(:datasetID => accessLevelDownload.datasetID, :permissionvalue => 2)
    user.permissions_b.create(:datasetID => accessLevelAnalyseDownload.datasetID, :permissionvalue => 6)

    visit "/users/#{user.user}/access/#{accessLevelNoAccess.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit "/users/#{user.user}/access/#{accessLevelPending.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit "/users/#{user.user}/access/#{accessLevelBrowse.datasetID}"
    page.should have_content({:browse => true, :analyse => false, :download => false}.to_json)

    visit "/users/#{user.user}/access/#{accessLevelAnalyse.datasetID}"
    page.should have_content({:browse => true, :analyse => true, :download => false}.to_json)

    visit "/users/#{user.user}/access/#{accessLevelDownload.datasetID}"
    page.should have_content({:browse => true, :analyse => false, :download => true}.to_json)

    visit "/users/#{user.user}/access/#{accessLevelAnalyseDownload.datasetID}"
    page.should have_content({:browse => true, :analyse => true, :download => true}.to_json)
  end

  scenario "accessing the API without permission" do
    # TODO: Perhaps IP address filtering for these actions?
    fail "Not yet implemented"
  end
end
