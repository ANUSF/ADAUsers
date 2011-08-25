source 'http://rubygems.org'

gem 'rails', '3.0.9'

# Rake 0.9.0 has this problem: http://stackoverflow.com/questions/5287121/undefined-method-task-using-rake-0-9-0-beta-4
gem 'rake', '~> 0.8.7'

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
gem 'escape_utils'

gem 'formtastic'
gem 'will_paginate', '~> 3.0.pre2'

if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  gem 'themenap', '~>0.1.6', :path => "#{ENV['GEMS_LOCAL']}/themenap"
else
  gem 'themenap', '~>0.1.6', :git => "git://github.com/ANUSF/themenap.git"
end

gem 'capistrano-ext'

group :development, :test do
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
  gem 'capistrano'
end
