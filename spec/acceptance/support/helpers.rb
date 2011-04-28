module HelperMethods
  def current_path
    URI.parse(current_url).path
  end

  def log_in_with(details={})
    visit "/session/new"

    fill_in "session_username", :with => details[:username]
    fill_in "session_password", :with => details[:password]
    click_button "Log in"

    page.should have_content("Login successful")
  end

  def log_in_as(user)
    log_in_with(:username => user.user, :password => user.user)
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
