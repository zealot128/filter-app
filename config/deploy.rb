set :application, 'pics.stefanwienert.de'
set :repo_url, 'git@git.stefanwienert.de:hrfilter'
set :rvm_ruby_version, '2.1.1'
set :rvm_type, :user

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/hrfilter.de'
set :scm, :git

set :format, :pretty
set :pty, true
# set :log_level, :info

set :linked_files, %w{config/database.yml .env}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :finishing, 'deploy:cleanup'
  # after 'restart', :ping_restart
end

desc 'ping server for passenger restart'
task :ping_restart do
  run_locally do
    execute 'curl --silent -I http://www.hrfilter.de'
  end
end



