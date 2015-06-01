set :application, 'hrfilter.de'
set :repo_url, 'git@localhost:stefan/hrfilter-de.git'
set :rvm_ruby_version, '2.1.1'
set :rvm_type, :user

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/hrfilter.de'
set :scm, :git

set :pty, true
# set :log_level, :info

set :linked_files, %w{config/database.yml config/secrets.yml config/email.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5


desc 'ping server for passenger restart'
task :ping_restart do
  run_locally do
    execute 'curl --silent -I http://www.hrfilter.de'
  end
end



desc "Update crontab with whenever"
task :update_crontab do
  on roles(:all) do
    within release_path do
      execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)}"
    end
  end
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :finishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
  after 'published', :update_crontab
  after 'finishing', :ping_restart
end
