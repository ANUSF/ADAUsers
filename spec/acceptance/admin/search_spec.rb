require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Search", %q{
  In order to find users
  As an administrator
  I want to be able to search for users
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    
    log_in_as(@admin) unless logged_in?
  end

  after(:all) do
    log_out if logged_in?
  end

  scenario "viewing the search page" do
    visit "/admin/users/search"

    page.should have_selector("input[type=submit][value='Search by username']")
    page.should have_selector("input[type=submit][value='Search by email address']")
    page.should have_selector("input[type=submit][value='List all users']")
  end

  scenario "searching by username" do
    User.make(:user => "Alice")
    User.make(:user => "Bob")

    visit "/admin/users/search"
    fill_in "search_q", :with => "alice"
    click_button "Search by username"

    find("table#search_results").should have_content("Alice")
    find("table#search_results").should_not have_content("Bob")
  end

  scenario "searching by surname" do
    User.make(:user => "Alice", :sname => "Evans")
    User.make(:user => "Bob", :sname => "Braithestraite")

    visit "/admin/users/search"
    fill_in "search_q", :with => "Evans"
    click_button "Search by surname"

    find("table#search_results").should have_content("Alice")
    find("table#search_results").should_not have_content("Bob")
  end

  scenario "searching by email address" do
    User.make(:user => "Alice", :email => "alice@toyworld.com.au")
    User.make(:user => "Bob",   :email => "bob@magnetmart.com.au")

    visit "/admin/users/search"
    fill_in "search_q", :with => "magnet"
    click_button "Search by email address"

    find("table#search_results").should_not have_content("Alice")
    find("table#search_results").should have_content("Bob")
  end

  scenario "searching by institution" do
    # Australian uni
    user = User.make
    visit "/admin/users/search"
    choose "Australian uni"
    select user.australian_uni.Longuniname, :from => 'search_uniid'
    click_button "Search by institution"
    page.should have_content(user.user)

    # Australian Government/Research
    user = User.make(:gov)
    visit "/admin/users/search"
    choose "Australian Government/Research"
    select user.australian_gov.name, :from => 'search_departmentid'
    click_button "Search by institution"
    page.should have_content(user.user)

    # Other Australian Institution
    user = User.make(:other_australian_affiliation)
    visit "/admin/users/search"
    choose "Other Australian Institution"
    select user.institution, :from => 'search_australian_other'
    click_button "Search by institution"
    page.should have_content(user.user)

    # Non-Australian Institution
    user = User.make(:foreign)
    visit "/admin/users/search"
    choose "Non-Australian Institution"
    select user.institution, :from => 'search_non_australian'
    click_button "Search by institution"
    page.should have_content(user.user)
  end

  scenario "displaying full list of users" do
    35.times { User.make }

    visit "/admin/users/search"
    click_button "List all users"

    all("tr").length.should == 30+1 # 1 for heading row
  end

  scenario "search returns no results" do
    10.times { User.make }
    query = "jfdjskdf"

    visit "/admin/users/search"
    fill_in "search_q", :with => query
    click_button "Search by username"

    page.should_not have_selector("table#search_results")
    page.should have_content("Your search '#{query}' returned no results.")
  end

  scenario "search results are paginated on long pages" do
    35.times { User.make }

    visit "/admin/users/search"
    click_button "List all users"
    
    page.should have_selector("a", :text => "2")
    all("tr").length.should == 30+1 # 1 for heading row
  end

  scenario "search displays all required columns" do
    User.make
    visit "/admin/users/search"
    click_button "List all users"
    
    columns = ['Username', 'Password', 'Role', 'Email', 'Institution', 'Type of work', 'Position', 'Date registered', 'Confirmed ACSPRI member?', 'Title', 'First name', 'Surname']

    columns.each do |col|
      find("thead").should have_content(col)
    end
  end

  scenario "pagination can be overridden" do
    35.times { User.make }
    
    visit "/admin/users/search"
    click_button "List all users"
    click_link("Show all")

    all("tr").length.should == 35+1+1 # 1 for heading row, 1 for admin user

    # Revert to paginated view
    click_link("Show in pages")
    all("tr").length.should == 30+1 # 1 for heading row
  end

  scenario "export results to CSV" do
    User.make(:user => "Alice")
    User.make(:user => "Bob")

    visit "/admin/users/search"
    fill_in "search_q", :with => "alice"
    click_button "Search by username"

    click_link("Export to CSV")

    page.should have_content("Alice")
    page.should_not have_content("Bob")
  end

  scenario "search is not accessible by non-administrators" do
    log_out
    visit "/admin/users/search"
    page.should have_content("You must be an administrator or publisher to access this page.")
    current_path.should == "/"
  end

end
