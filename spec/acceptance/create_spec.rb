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


  scenario "edit page shows correct fields and values" do
    user = User.make
    log_in_as(user)

    visit "/users/#{user.user}/edit"
    
    form = find("form#edit_user_#{user.user}")

    fields = [{:name => 'title', :type => :select},
              {:name => 'fname', :type => :text_field},
              {:name => 'sname', :type => :text_field},
              {:name => 'email', :type => :text_field},
              {:name => 'email_confirmation', :type => :text_field, :value => ''},
                
              {:name => 'position', :type => :select, :value => user[:position]},
              {:name => 'otherpd', :type => :text_field},
                
              {:name => 'action', :type => :select},
              {:name => 'otherwt', :type => :text_field},
              
              {:name => 'countryid', :type => :select},
              
              {:name => 'austinstitution', :type => :radio},
              {:name => 'uniid', :type => :select},
              {:name => 'departmentid', :type => :select},
              {:name => 'other_australian_affiliation', :type => :text_field},
              {:name => 'other_australian_affiliation_type', :type => :select},
              
              {:name => 'non_australian_affiliation', :type => :text_field},
              {:name => 'non_australian_type', :type => :select}]

    fields.each do |field|
      should_have field[:type], :named => "user[#{field[:name]}]", :value => (field[:value] || user[field[:name]]), :within => form
    end

    log_out
  end


  # should_have :text_field, :named => 'user[email]', :value => user.email, :within => find("#user_details")
  def should_have(type, opts={})
    raise ArgumentError, ":named is required" unless opts.has_key? :named
    opts = {:value => '', :within => page}.merge(opts)

    name_attr = "[name='#{opts[:named]}']"
    value_attr = opts[:value].present? ? "[value='#{opts[:value]}']" : ""

    if type == :text_field
      opts[:within].should have_selector("input#{name_attr}#{value_attr}")
    elsif type == :select
      if opts[:value].present?
        opts[:within].should have_selector("select#{name_attr} option#{value_attr}[selected='selected']")
      else
        opts[:within].should_not have_selector("select#{name_attr} option[selected='selected']")
      end
    elsif type == :radio
      if opts[:value].present?
        opts[:within].should have_selector("input[type='radio']#{name_attr}#{value_attr}[checked='checked']")
      else
        opts[:within].should_not have_selector("input[type='radio']#{name_attr}[checked='checked']")
      end
    else
      raise ArgumentError, "Unknown field type: #{type}"
    end
  end

 end
