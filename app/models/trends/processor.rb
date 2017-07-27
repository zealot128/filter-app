class Trends::Processor
  REGEX = /[^\p{word}-]/.freeze

  def self.process_week(date_in_week)
    news_this_week = NewsItem.where(created_at: date_in_week.to_time.all_week)
    news_this_week.each do |ni|
      new(ni).run
    end
  end

  def initialize(news_item)
    @news_item = news_item
    @calendar_week = @news_item.published_at&.strftime("%G%W")
  end

  # rubocop:disable Style/ClassVars
  def stopwords
    @@stopwords ||= Trends::Word.where(ignore: true).pluck(:word)
  end

  def run
    return unless @calendar_week
    return if @news_item.source.language == 'english'

    text = @news_item.title
    words = text.to_s.split(REGEX).
      select { |i| i[/^[A-Z]|^\d/] }.
      map(&:downcase).
      reject { |i| i.length < 3 || stopwords.include?(i) }.
      uniq
    bigrams = words.each_cons(2).to_a
    trigrams = words.each_cons(3).to_a

    all_words = words + bigrams.map { |j| j.join(' ') } + trigrams.map { |j| j.join(' ') }
    trend_words = Trends::Word.where(word: all_words)
    Trends::Usage.where(news_item_id: @news_item.id).delete_all
    trend_words.each do |tw|
      Trends::Usage.create(
        news_item_id: @news_item.id,
        source_id: @news_item.source_id,
        word_id: tw.top_parent.id,
        calendar_week: @calendar_week,
        date: @news_item.published_at
      )
      all_words.delete(tw.word)
    end
    all_words.each do |word|
      tw = Trends::Word.create(word: word, ignore: false)
      Trends::Usage.create(
        news_item_id: @news_item.id,
        source_id: @news_item.source_id,
        word_id: tw.id,
        calendar_week: @calendar_week,
        date: @news_item.published_at
      )
    end
  end
end
