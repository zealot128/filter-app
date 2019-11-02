ignore = YAML.load_file('db/seeds/trends/ignore.yml')
ignore.each do |w|
  word = Trends::Word.where(word: w).first_or_initialize
  word.ignore = true
  word.save if word.changed?
end

trends = YAML.load_file('db/seeds/trends/trends.yml')
trends.each do |trend|
  trend_object = Trends::Trend.where(name: trend[:name]).first_or_create!
  trend[:words].each do |w|
    word = Trends::Word.where(word: w).first_or_create
    trend_object.words << word unless trend_object.words.include?(word)
  end
end
