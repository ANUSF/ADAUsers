require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :application, "ADAUsers"
set :repository,  "git@github.com:ANUSF/ADAUsers.git"

set :scm, :git
set :deploy_via, :remote_cache

default_run_options[:pty] = true
default_run_options[:tty] = true

ssh_options[:paranoid] = false
ssh_options[:port] = 22
ssh_options[:forward_agent] = true
ssh_options[:compression] = false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

set(:branch) do
  Capistrano::CLI.ui.ask "Specify a tag name to deploy:"
end

after 'deploy:setup', :create_extra_dirs
after 'deploy:setup', :copy_database_yml

before 'deploy:update_code', :echo_ruby_env

after 'deploy:update', :symlinks
after 'deploy:update', :deploy_log

desc "create additional shared directories during setup"
task :create_extra_dirs, :roles => :app do
  run "mkdir -m 0755 -p #{shared_path}/db"
end

desc "copy the database configuration to the server"
task :copy_database_yml, :roles => :app do
  prompt = "Specify a database configuration file to copy to the server:"
  path = Capistrano::CLI.ui.ask prompt
  put File.read("#{path}"), "#{shared_path}/database.yml", :mode => 0600
end

task :echo_ruby_env do
  puts "Checking ruby env ..."
  run "ruby -v"
  run "export RAILS_ENV='#{rails_env}'"
end

task :symlinks, :roles => :app do
  run "ln -nfs #{shared_path}/db/* #{current_path}/db/"
  run "ln -nfs #{shared_path}/database.yml #{current_path}/config/"
end

task :deploy_log, :roles => :app do
  run "touch #{current_path}/tmp/deploy-log.txt"
  run "echo \"Deployed at #{Time.now.strftime('%Y-%m-%d %I:%M')}\" > #{current_path}/tmp/deploy-log.txt"
end
