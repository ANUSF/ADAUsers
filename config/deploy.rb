require 'bundler/capistrano' # use bundler's support for capistrano to make it easy
require 'capistrano/ext/multistage'

set :application, "ADAUsers"
set :repository,  "git@github.com:ANUSF/ADAUsers.git"

set :scm, :git
set :deploy_via, :remote_cache

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user,        "deploy"
set :use_sudo,    true
set :deploy_to,   "/data/ADAUsers"

default_run_options[:pty] = true
default_run_options[:tty] = true

ssh_options[:paranoid] = false
ssh_options[:port] = 22
ssh_options[:forward_agent] = true
ssh_options[:compression] = false



# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:

namespace :deploy do
  task :start do
    run "cd #{current_path} && nohup script/rails server -d -p 4000"
  end
  task :stop do
    run "kill `cat #{current_path}/tmp/pids/server.pid`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "kill `cat #{current_path}/tmp/pids/server.pid`"
    run "cd #{current_path} && nohup script/rails server -d -p 4000"
  end
end

set(:branch) do
  Capistrano::CLI.ui.ask "Open the hatch door please HAL: (specify a tag name to deploy):"
end

after 'deploy:update', :symlinks
after 'deploy:update', :deploy_log
before 'deploy:update_code', :echo_ruby_env

task :echo_ruby_env do
  puts "Checking ruby env ..."
  run "ruby -v"
  run "export RAILS_ENV='#{rails_env}'"
end

task :symlinks, :roles => :app do
  run "ln -nfs #{shared_path}/db/* #{current_path}/db/"
end

task :deploy_log, :roles => :app do
  run "touch #{current_path}/tmp/deploy-log.txt"
  run "echo \"Deployed at #{Time.now.strftime('%Y-%m-%d %I:%M')}\" > #{current_path}/tmp/deploy-log.txt"
end
