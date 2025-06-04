# Set your full path to application.
app_path = "/apps/hrcollect/prod/current"

# Set unicorn options
worker_processes 3
preload_app true
timeout 180
listen 6000 # "127.0.0.1"

# Spawn unicorn master worker for user apps (group: apps)
user 'stefan', 'stefan'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"

before_fork do |server, _worker|
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end
  I18n.t("active_record")

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  I18n.t('activerecord')
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection
end
