require File.dirname(__FILE__) + '/acceptance_helper'

feature "Create", %q{
  In order to use the site
  As a prospective user
  I want to be able to sign up
} do

  fixtures :templates

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
    user.user_ejb.password.should == UserEjb::TOKEN_PASSWORD
    user.role_cms.should == 'member'
    page.should have_content("Registration successful!")

    # And I should receive a registration email
    email = ActionMailer::Base.deliveries.last
    email.subject.should == "User Nesstar Registration"
    email.encoded.should match(/Thank you for registering with ASSDA's online Nesstar facility./)
    email.encoded.should match(/#{user.user}/)
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

    # And the password fields should be blank
    page.should have_selector("#user_password[value='']")
    page.should have_selector("#user_password_confirmation[value='']")

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


  scenario "editing a user" do
    base_data = [{:type => :select, :name => 'title', :value => 'Miss'},
                 {:type => :text, :name => 'fname', :value => 'newfname'},
                 {:type => :text, :name => 'sname', :value => 'newsname'},
                 {:type => :text, :name => 'email', :value => 'new@email.com'},
                 {:type => :select, :name => 'position', :value => 'Researcher'},
                 {:type => :text, :name => 'otherpd', :value => 'otherpdnew'},
                 {:type => :select, :name => 'action', :value => 'Pure research'},
                 {:type => :text, :name => 'otherwt', :value => 'otherwtnew'}]


    # Australian university
    user = User.make(:foreign)
    test_edit(user, base_data +
              [{:type => :select, :name => 'countryid', :value_label => 'Australia', :value => Country.find_by_Countryname('Australia').id},
               {:type => :radio, :name => 'austinstitution', :value => 'Uni'},
               {:type => :select, :name => 'uniid', :value_label => 'University of Melbourne', :value => AustralianUni.find_by_Longuniname('University of Melbourne').id}])
    user.destroy

    # Australian government
    user = User.make(:foreign)
    test_edit(user, base_data +
              [{:type => :select, :name => 'countryid', :value_label => 'Australia', :value => Country.find_by_Countryname('Australia').id},
               {:type => :radio, :name => 'austinstitution', :value_label => 'Government/Research', :value => 'Dept'},
               {:type => :select, :name => 'departmentid', :value_label => 'The Treasury', :value => AustralianGov.find_by_name('The Treasury').id}])
    user.destroy

    # Australian other affiliation
    user = User.make(:foreign)
    test_edit(user, base_data +
              [{:type => :select, :name => 'countryid', :value_label => 'Australia', :value => Country.find_by_Countryname('Australia').id},
               {:type => :radio, :name => 'austinstitution', :value => 'Other'},
               {:type => :text, :name => 'other_australian_affiliation', :value => 'Other Aus aff'},
               {:type => :select, :name => 'other_australian_type', :value => 'Media'}])
    user.destroy

    # Non-australian affiliation
    user = User.make
    test_edit(user, base_data +
              [{:type => :select, :name => 'countryid', :value_label => 'New Zealand', :value => Country.find_by_Countryname('New Zealand').id},
               {:type => :text, :name => 'non_australian_affiliation', :value => 'nainew'},
               {:type => :select, :name => 'non_australian_type', :value => 'Private company'}])
    user.destroy
  end



#  scenario "editing without permission" do
#    # Anonymous user
#    log_out
#    visit "/admin/users/#{@user.user}/edit"
#    page.should have_content("You must be an administrator or publisher to access this page.")
#    current_path.should == "/"
#    
#
#    log_in_as(@user)
#
#    # Own edit page
#    visit "/admin/users/#{@user.user}/edit"
#    page.should have_content("User details")
#    page.should_not have_content("Category A Datasets")
#
#    # Someone else's edit page when not an admin
#    user2 = User.make
#    visit "/admin/users/#{user2.user}/edit"
#    page.should have_content("You may not access another user's details.")
#    current_path.should == "/"
#
#    log_out
#  end



  ############################################################

  protected

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


  def test_edit(user, data)
    #puts "=" * 60
    log_in_as(user)


    # Check that user differs from these values
    data.each do |field|
      #puts "Comparing #{field[:name]}: '#{user[field[:name]]}' to '#{field[:value]}'"
      user.send(field[:name]).should_not == field[:value]
    end


    # Perform the edit
    visit "/users/#{user.user}/edit"
    data.each do |field|
      name = "user_#{field[:name]}"
      value = field[:value_label] || field[:value]

      case field[:type]
      when :select
        select value, :from => name
      when :text
        fill_in name, :with => value
      when :radio
        choose value
      else
        raise ArgumentError, "Unknown field type: #{field[:type]}"
      end
    end
    click_button "Submit"

    # Check that the user has been updated
    #puts "-" * 60
    user.reload
    data.each do |field|
      #puts "Comparing #{field[:name]}: '#{user[field[:name]]}' to '#{field[:value]}'"
      user.send(field[:name]).should == field[:value]
    end


    # Clean up
    log_out
  end

 end
