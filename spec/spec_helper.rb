require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Make application helper methods accessible in tests
  include ApplicationHelper
  
  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # Sham resets
    config.before(:all)    { Sham.reset(:before_all)  }
    config.before(:each)   { Sham.reset(:before_each) }

    # Generate some test data
    config.before(:all) do
      Country.make
      AustralianUni.make
      RoleEjb.make(:id => "affiliateusers")
      RoleEjb.make(:id => "administrator")
    end
  end

end

Spork.each_run do
  # Without this, models are not being reloaded between test runs
  silence_warnings do
    Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }
  end
end
