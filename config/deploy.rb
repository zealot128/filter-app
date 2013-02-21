require 'bundler/capistrano'
require 'capistrano-unicorn'
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
#set :local_repository, "nameOfHostFromSSHConfig:/srv/git/myapp.git"
set :user, "stefan"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true



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
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
