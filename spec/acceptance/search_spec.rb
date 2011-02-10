require File.dirname(__FILE__) + '/acceptance_helper'

feature "Search", %q{
  In order to find users
  As an administrator
  I want to be able to search for users
} do

  before(:each) do
    # Delete all users with names like "alice" or "bob"
    ['alice', 'bob'].each do |name|
      User.where("user LIKE ?", "%%#{name}%%").destroy_all
    end
  end

  scenario "viewing the search page" do
    visit "/user/search"

    page.should have_selector("input[type=submit][value='Search by username']")
    page.should have_selector("input[type=submit][value='Search by email address']")
    page.should have_selector("input[type=submit][value='List all users']")
  end

  scenario "searching by username" do
    User.make(:user => "Alice")
    User.make(:user => "Bob")

    visit "/user/search"
    fill_in "search_q", :with => "alice"
    click_button "Search by username"

    find("table#search_results").should have_content("Alice")
    find("table#search_results").should_not have_content("Bob")
  end

  scenario "searching by email address" do
    User.make(:user => "Alice", :email => "alice@toyworld.com.au")
    User.make(:user => "Bob",   :email => "bob@magnetmart.com.au")

    visit "/user/search"
    fill_in "search_q", :with => "magnet"
    click_button "Search by email address"

    find("table#search_results").should_not have_content("Alice")
    find("table#search_results").should have_content("Bob")
  end

  scenario "displaying full list of users" do
    visit "/user/search"
    click_button "List all users"

    all("tr").length.should == 30+1 # 1 for heading row
  end

  scenario "search returns no results" do
    query = "jfdjskdf"

    visit "/user/search"
    fill_in "search_q", :with => query
    click_button "Search by username"

    page.should_not have_selector("table#search_results")
    page.should have_content("Your search '#{query}' returned no results.")
  end

  scenario "search results are paginated on long pages" do
    User.count.should be > 100

    visit "/user/search"
    click_button "List all users"
    
    find("a").should have_content("2")
    all("tr").length.should == 30+1 # 1 for heading row
  end

  scenario "search displays all required columns" do
    visit "/user/search"
    click_button "List all users"
    
    # User	Password	Role	Email	Institution	Action	Position	Dateregistered	Acsprimember	Countryid	Uniid	Departmentid	Institutiontype	Fname	Sname	Title	Austinstitution	Otherpd	Otherwt
    columns = ['Username', 'Password', 'Role', 'Email', 'Institution', 'Type of work', 'Position', 'Date registered', 'ACSPRI member?', 'Country', 'University', 'Department', 'Institution type', 'First name', 'Surname', 'Title', 'Australian Institution Type', 'Other Position Details', 'Other Work Type']

    columns.each do |col|
      find("thead").should have_content(col)
    end
  end

  # TODO
  scenario "search is not accessible by non-administrators" do
  end

end
