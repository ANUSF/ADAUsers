source 'http://rubygems.org'

gem 'rails'

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
