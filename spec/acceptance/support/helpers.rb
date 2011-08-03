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
    log_in_with(:username => user.user, :password => user.user*3)
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


  # Test for at least one element matching a selector and passing further block-given tests.
  # Useful for scoping multiple requirement checks to a single container element.
  #
  # Usage:
  #
  # selector_exists?(".my-div") do |e|
  #   e.has_content?("foo") and e.has_content?("bar")
  # end
  def selector_exists?(selector, &block)
    find_selector(selector, &block) != nil
  end

  # Locate the first element that matches the given selector and passes further block-given tests.
  def find_selector(selector)
    matching_e = nil

    all(selector).each do |e|
      if yield e
        matching_e = e
        break
      end
    end

    matching_e
  end

end

RSpec.configuration.include HelperMethods, :type => :acceptance
