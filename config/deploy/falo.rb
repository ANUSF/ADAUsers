$:.unshift(File.join(ENV['rvm_path'], 'lib'))
require 'rvm/capistrano'

set :rvm_ruby_string, 'ruby-1.9.2-p180@ada-users'
set :rvm_type, :user

role :web, "falo"                   # Your HTTP server, Apache/etc
role :app, "falo"                   # This may be the same as your `Web` server
role :db,  "falo", :primary => true # This is where Rails migrations will run

set :rails_env, "production"

set :user,        "olaf"
set :use_sudo,    true
set :deploy_to,   "/data/httpd/ADAUsers"
