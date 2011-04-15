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
    
  end

  scenario "enquiring about user access rights" do
    
  end

  scenario "accessing the API without permission" do
    # TODO: Perhaps IP address filtering for these actions?
    fail "Not yet implemented"
  end
end
