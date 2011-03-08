module HelperMethods
  def should_be_on(path)
    current_path = URI.parse(current_url).path
    current_path.should == path
  end

  def log_in_as(user)
    visit "/session/new"

    fill_in "session_username", :with => user.user
    fill_in "session_password", :with => user.password
    click_button "Log in"

    page.should have_content("Login successful")
  end

  def logged_in?
    visit "/"
    page.has_selector?("a", :text => "Log out")
  end

  def log_out
    visit "/"
    click_link "Log out"
    page.should have_content("You have successfully logged out.")
  end

end

RSpec.configuration.include HelperMethods, :type => :acceptance
