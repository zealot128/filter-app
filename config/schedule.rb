set :output, "#{Dir.pwd}/log/cron.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"

every 1.hour do
  runner 'NewsItem.cronjob'
end

every 1.hour do
  runner "Source.cronjob"
end

every 1.day, at: '03:15' do
  runner 'NewsItem::LinkageCalculator.run()'
end

# every 1.day, at: '03:23' do
#   runner 'MailSubscription.cleanup'
# end

every 1.day, at: '03:25' do
  runner 'DuplicateFinder.run'
end

every :monday, at: '9am' do
  runner 'Newsletter::Mailing.cronjob'
end

every 1.day, at: '5:00 am' do
  rake "-s sitemap:refresh"
end

every 1.day, at: '09:33' do
  runner "TwitterPosting.cronjob"
end
every 1.day, at: '12:20' do
  runner "TwitterPosting.cronjob"
end
every 1.day, at: '14:14' do
  runner "TwitterPosting.cronjob"
end
every 1.day, at: '16:33' do
  runner "TwitterPosting.cronjob"
end
every 1.day, at: '19:12' do
  runner "TwitterPosting.cronjob"
end
