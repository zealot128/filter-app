
ActiveRecord::Base.logger.silence {
  110.times do |week|
    print week.weeks.ago.to_date.to_s
    Trends::Processor.process_week(week.weeks.ago)
  end
}
