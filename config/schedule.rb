set :output, "/var/www/hrfilter.de/shared/log/cron.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"


every 1.hour do
  runner 'NewsItem.cronjob'
end

every 1.hour do
  runner "Source.cronjob"
end

every 1.day, at: '03:15' do
  runner 'LinkageCalculator.run()'
end

every 1.day, at: '03:23' do
  runner 'MailSubscription.cleanup'
end

every 1.day, at: '03:25' do
  runner 'DuplicateFinder.run'
end

every :sunday, at: '6pm' do
  NewsletterMailer.cronjob
end
