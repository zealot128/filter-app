set :output, "#{Dir.pwd}/log/cron.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"

every 1.hour do
  runner 'CATCH_ALL { NewsItem.cronjob }'
end

every 1.hour do
  runner "CATCH_ALL { Source.cronjob }"
end

every '0 9-17 * * *' do
  runner "CATCH_ALL { PushNotificationManager.run }"
end

every 1.day, at: '03:15' do
  runner 'CATCH_ALL { NewsItem::LinkageCalculator.run() }'
end

every 1.day, at: '03:25' do
  runner 'CATCH_ALL { DuplicateFinder.run }'
  runner 'CATCH_ALL { NewsItem.cleanup }'
end

every :week do
  runner 'CATCH_ALL { Ahoy::Visit.cronjob }'
end

every :monday, at: '9am' do
  runner 'CATCH_ALL { Newsletter::Mailing.cronjob }'
end

every :sunday, at: '11pm' do
  runner 'CATCH_ALL { Trends::Cleanup.run }'
end

every :monday, at: '7am' do
  runner 'CATCH_ALL { Trends::Processor.cronjob }'
end

every :day, at: '9am' do
  runner 'CATCH_ALL { Newsletter::Inactivity.cronjob }'
end

every 1.day, at: '04:12' do
  runner 'CATCH_ALL { ClicksSynchronization.run }'
end

every 1.day, at: '5:00 am' do
  rake "-s sitemap:refresh"
end

%w[09 10 12 14 16 18].each do |h|
  minute = rand(0..59)
  every 1.day, at: "#{h}:#{sprintf('%02d', minute)}" do
    runner "CATCH_ALL { TwitterPosting.cronjob }"
  end
end
