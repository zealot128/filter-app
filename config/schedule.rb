set :output, "/apps/hrcollect/prod/current/log/cron_log.log"

every 15.minutes do
  runner "Source.cronjob"
end

every 1.hour do
  runner ' NewsItem.cronjob'
end
