set :output, "/apps/hrcollect/prod/current/log/cron_log.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"

every 15.minutes do
  runner "Source.cronjob"
end

every 1.hour do
  runner ' NewsItem.cronjob'
end
