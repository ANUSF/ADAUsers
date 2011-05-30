source 'http://rubygems.org'

gem 'rails', '3.0.7'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
else
  gem 'mongrel', '~> 1.2.0.pre2'
  gem 'mysql2', '~> 0.2.7' # the 0.3.x versions need Rails 3.1
  gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3'
end

gem 'ruby-openid',  :require => 'openid'
gem 'bcrypt-ruby'
gem 'composite_primary_keys' # For support of Nesstar database
gem 'json_pure', :require => 'json'

gem 'formtastic'
gem 'will_paginate', '~> 3.0.pre2'

if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  gem 'themenap', '~>0.1.4', :path => "#{ENV['GEMS_LOCAL']}/themenap"
else
  gem 'themenap', '~>0.1.4', :git => "git://github.com/ANUSF/themenap.git"
end

gem 'capistrano-ext'

group :development, :test do
  gem 'barista'
  gem 'therubyracer'
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
  gem 'capistrano'
end
