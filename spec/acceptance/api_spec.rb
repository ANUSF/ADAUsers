require File.dirname(__FILE__) + '/acceptance_helper'

feature "API", %q{
  In order to fetch user information
  As a remote website
  I want to request information via a JSON API
} do

  before(:each) do
    AccessLevel.destroy_all
  end


  scenario "fetching user role" do
    user = User.make
    visit_with_api_key "/users/#{user.user}/role"
    page.should have_content({:nesstar => "affiliateusers", :cms => "member"}.to_json)
  end

  scenario "fetching user details" do
    user = User.make
    visit_with_api_key "/users/#{user.user}/details"
    page.should have_content user.attributes_api.to_json
  end

  scenario "fetching list of privileged users" do
    users = [User.make(:administrator), User.make(:publisher)]
    visit_with_api_key "/users/privileged"

    users.each do |user|
      page.should have_content user.attributes_api.to_json
    end
  end

  scenario "enquiring about user access rights to category A datasets" do
    user = User.make

    accessLevelNoAccess = AccessLevel.make
    accessLevelPending = AccessLevel.make
    accessLevel = AccessLevel.make
    user.permissions_a.create(:datasetID => accessLevelPending.datasetID, :permissionvalue => 0)
    user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelNoAccess.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)
    
    visit_with_api_key "/users/#{user.user}/access/#{accessLevelPending.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevel.datasetID}"
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

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelNoAccess.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelPending.datasetID}"
    page.should have_content({:browse => false, :analyse => false, :download => false}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelBrowse.datasetID}"
    page.should have_content({:browse => true, :analyse => false, :download => false}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelAnalyse.datasetID}"
    page.should have_content({:browse => true, :analyse => true, :download => false}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelDownload.datasetID}"
    page.should have_content({:browse => true, :analyse => false, :download => true}.to_json)

    visit_with_api_key "/users/#{user.user}/access/#{accessLevelAnalyseDownload.datasetID}"
    page.should have_content({:browse => true, :analyse => true, :download => true}.to_json)
  end

  scenario "accessing the API without permission" do
    user = User.make
    accessLevel = AccessLevel.make

    paths = ["/users/#{user.user}/role",
             "/users/#{user.user}/details",
             "/users/#{user.user}/access/#{accessLevel.datasetID}",
             "/users/privileged"]

    paths.each do |path|
      # Accessing path with permission is allowed
      visit_with_api_key path
      page.driver.status_code.should == 200
      body.strip.should_not be_empty

      # Accessing path without permission is forbidden
      visit path
      page.driver.status_code.should == 403
    end
  end


  protected
  def visit_with_api_key(path)
    visit "#{path}?api_key=#{Secrets::API_KEY}"
  end
end
