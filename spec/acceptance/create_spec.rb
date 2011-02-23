require File.dirname(__FILE__) + '/acceptance_helper'

feature "Create", %q{
  In order to use the site
  As a prospective user
  I want to be able to sign up
} do

  scenario "successfully signing up" do
    # Given I am on the new user page
    visit "/users/new"

    # When I fill in all the fields and press "Submit"
    u = User.make_unsaved
    fill_in "user_user", :with => u.user
    fill_in "user_password", :with => u.password
    fill_in "user_password_confirmation", :with => u.password
    select u.title, :from => "user_title"
    fill_in "user_fname", :with => u.fname
    fill_in "user_sname", :with => u.sname
    fill_in "user_email", :with => u.email
    fill_in "user_email_confirmation", :with => u.email
    select u.position, :from => "user_position"
    select u.action, :from => "user_action"
    select u.country.Countryname, :from => "user_countryid"
    choose u.austinstitution
    select u.australian_uni.Longuniname, :from => "user_uniid"
    click_button "Submit"

    # Then a new user should exist, and I should see "Registration successful!"
    user = User.find_by_user!(u.user)
    user.email.should == u.email
    page.should have_content("Registration successful!")
  end


  scenario "encountering validation errors" do
    # Given I am on the new user page
    visit "/users/new"

    # When I do not fill in any fields and I press "Submit"
    initial_user_count = User.count
    click_button "Submit"

    # Then a new user should not be created
    User.count.should == initial_user_count

    # And I should see some errors
    page.should have_selector("p.inline-errors")

    # And I should see "Please check the values you filled in."
    page.should have_content("Please check the values you filled in.")
  end
end
