our_sources = Source.where('url like ? or url like ? ', '%pludoni%', '%empfehlungsbund%')

[1.year.ago, Time.zone.now].each do |time|
  from = time.at_beginning_of_year
  to = time.at_end_of_year
  puts "Kalenderjahr #{time.year}"
  clicks = Impression.where('created_at between ? and ?', from, to).count
  puts "  #{clicks} Klicks im Kalenderjahr insgesamt"

  count = Impression.where('created_at between ? and ?', from, to).where(impressionable_id: NewsItem.where(source_id: our_sources).select('id')).count
  puts "  #{count} Klicks auf pludoni Quellen"
end
