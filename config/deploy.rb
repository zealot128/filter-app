require 'bundler/capistrano'
set :application, "HRcollect"
set :repository,  "git://localhost/.com/zealot128/AutoShare-Gallery.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run

after "deploy:restart", "deploy:cleanup"
set :deploy_to, "/apps/hrcollect/prod"
set :repository, "file:///apps/hrcollect/dev"
set :local_repository, "file://."
set :user, "stefan"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
set :rvm_install_pkgs, %w[libyaml openssl]
before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_pkgs'  # install RVM packages before Ruby
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
require "rvm/capistrano"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

logger.level = Logger::INFO



namespace :deploy do
  task :start, :roles => :app do
    unicorn.start
  end
  task :stop, :roles => :app do
    unicorn.stop
  end
  desc "Restart Application"
  task :restart, :roles => :app do
    unicorn.reload
  end
end

task :symlink_assets do
  run "ln -nfs #{shared_path}/system #{release_path}/public/system"
end
after "deploy:update_code", :symlink_assets
after 'deploy:update_code', 'deploy:migrate'

after "deploy:setup", "setup"
task :setup, :roles => [:app, :db, :web] do
  run "mkdir -p -m 775 #{release_path} #{shared_path}/system && mkdir -p -m 777 #{shared_path}/log"
end

require 'capistrano-unicorn'
