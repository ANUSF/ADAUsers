source 'http://rubygems.org'

gem 'rails', '3.0.19'

gem 'mongrel', '~> 1.2.0.pre2'
gem 'mysql2', '~> 0.2.7' # the 0.3.x versions need Rails 3.1
gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3' # for CentOS 5.5

gem 'ruby-openid',  :require => 'openid'
gem 'bcrypt-ruby'
gem 'composite_primary_keys' # For support of Nesstar database
gem 'escape_utils'

gem 'formtastic'
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
