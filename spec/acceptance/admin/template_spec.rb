require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Administer templates", %q{
  In order to keep the site templates current
  As an administrator
  I want to create, edit, update and delete templates
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?
  end

  after(:all) do
    log_out if logged_in?
  end


  scenario "listing templates" do
    # Given there are some templates
    templates = []
    3.times { templates << Template.make }

    # When I go to the templates page
    visit "/"
    click_link "Manage templates"

    # Then I should see a link to create a new template
    page.should have_selector "a", :text => "Create new template"

    # And I should see some templates
    templates.each do |t|
      page.should have_selector "td a", :text => t.name
    end
  end

  scenario "creating a template" do
    # When I go to the create template page
    visit "/"
    click_link "Manage templates"
    click_link "Create new template"

    # And I fill out the form and click submit
    select "Email", :from => 'template_doc_type'
    fill_in 'template_name', :with => "name"
    fill_in 'template_title', :with => "title"
    fill_in 'template_body', :with => "body"
    click_button "Create Template"

    # Then I should see flash confirm + the new template in the table
    page.should have_content "Your template has been created."
    page.should have_selector "td a", :text => "name"
    page.should have_selector "td", :text => "title"
  end

end
