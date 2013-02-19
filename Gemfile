source 'https://rubygems.org'

gem 'rails', '~> 3.1.0'

gem 'thin' # use 'bundle exec thin start' instead of 'rails s' for now

#gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3' # for CentOS 5.5
gem 'sqlite3'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery is the default JavaScript library in Rails 3.1+
gem 'jquery-rails'

gem 'ruby-openid',  :require => 'openid'
gem 'bcrypt-ruby'
gem 'composite_primary_keys' # For support of Nesstar database
gem 'escape_utils'

gem 'formtastic', '~> 1.2.4'  # Convert to 2.2 API later
gem 'will_paginate', '~> 3.0.pre2'

if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  gem 'themenap', '~>0.1.7', :path => "#{ENV['GEMS_LOCAL']}/themenap"
else
  gem 'themenap', '~>0.1.7', :git => "git://github.com/ANUSF/themenap.git"
end

gem 'capistrano-ext'

group :development, :test do
  gem 'ZenTest', '4.5.0'
  gem 'barista'
  gem 'therubyracer'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'    # So you can do Then show me the page
  gem 'autotest'
  gem 'steak'
  gem 'faker'
  gem 'machinist'
  gem 'database_cleaner'
  gem 'spork'
  gem 'simplecov'
end
