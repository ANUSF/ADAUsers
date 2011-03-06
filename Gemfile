source 'http://rubygems.org'

gem 'rails', '3.0.5'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
else
  gem 'mongrel', '~> 1.2.0.pre2'
  gem 'mysql2'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

gem 'ruby-openid',  :require => 'openid'
gem 'formtastic'
gem 'json_pure', :require => 'json'
gem 'barista'
gem 'will_paginate', '~> 3.0.pre2'
gem 'composite_primary_keys', '=3.1.0' # For support of Nesstar database

group :development, :test do
  gem 'rspec-rails', '= 2.0.1'
  gem 'capybara'
  gem 'launchy'    # So you can do Then show me the page
  gem 'autotest'
  gem 'steak', '>= 1.0.0.rc.1'
  gem 'faker'
  gem 'machinist' , '= 1.0.6'
  gem 'database_cleaner'
  gem 'spork', '~> 0.9.0.rc'
  gem 'simplecov', '>= 0.4.0', :require => false, :group => :test
  gem 'newrelic_rpm'
end
