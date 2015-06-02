set :output, "/var/www/hrfilter.de/shared/log/cron.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"

every 15.minutes do
  runner "Source.cronjob"
end

every 1.hour do
  runner ' NewsItem.cronjob'
end

every 1.day do
  runner 'LinkageCalculator.run()'
end

every 1.day do
  runner 'DuplicateFinder.run'
end
