class Trends::Processor
  REGEX = /[^\p{word}-]/.freeze

  STOPWORDS = %w[
    die der und das für den auf eine von mit ist ein sie sich zum auch dem als
    mehr nicht des wie bei sind aus einer werden hat wird oder über zur vor einen
    einem nach nur dass kann hier durch können diese aber noch haben
    wenn was ihre sein unter wir man bis dann dabei geht alle
    damit eines immer keine ihrer dieser sondern gibt doch muss viele diesem ganz
    www https in den of than then of the by from have what you are
    also dies müssen ihr schon selbst anderen vom zwei weitere beim neue
    ihren finden wieder wer nun ich denn viel welche dieses gilt ihnen ohne
    allem steht etwas amp besonders weil mal war beispiel allerdings soll zwar
    www diesen unsere macht drei kommen will waren ersten rund gerade eigene
    lässt einmal anzeige ihrem sogar fall weiter jeder denen einfach seine
    mir mich dir dich meine mein meines deine deines sein ihr ihrs ihre ihrem ihren
    unser unsere kann können es jahr egal ob ab an je zu uhr könnt im in
    this is after their has been how which other these since could there those before when
    it hinaus darüber findest but not
    januar februar märz april mai juni juli august september oktober november dezember
    reply retweet share retweets likes follow embed
  ].freeze

  def self.cronjob
    process_week 1.day.ago

    all = Trends::Word.
      where('trends_usages.calendar_week = ?', 1.day.ago.strftime("%G%W")).
      where(ignore: false).
      joins(:usages).
      group(:id).
      order('count desc').
      having('count(distinct source_id) >= 2').
      limit(25).
      select("trends_words.*, count(distinct source_id) as count")
    words = []
    words += all.trigram
    words += all.bigram
    words += all.single
    TrendMailer.week_trends(words).deliver_now
  end

  def self.process_week(date_in_week)
    news_this_week = NewsItem.without_dupes.where(created_at: date_in_week.to_time.all_week)
    news_this_week.each do |ni|
      new(ni).run
    end
    Trends::DupeFinder.cronjob(date_in_week: date_in_week)
  end

  def initialize(news_item)
    @news_item = news_item
    @calendar_week = @news_item.published_at&.strftime("%G%W")
  end

  def run
    print '-' if ENV['USER'] # not in cron
    return unless @calendar_week
    # return if @news_item.source.language == 'english'

    Trends::Usage.where(news_item_id: @news_item.id).delete_all
    create_usages @news_item.title.to_s, :title
    if @news_item.plaintext
      pl = ActionController::Base.helpers.strip_tags(@news_item.plaintext.to_s)
      pl.remove!(%r{https?://[^\s,;\!]+})
      create_usages pl, :plaintext
    end
  end

  def create_usages(text, usage_type)
    usage_type = Trends::Usage.usage_types[usage_type.to_s]
    words = text.to_s.split(REGEX).
      # select { |i| i[/^[A-Z]|^\d/] }.
      map(&:downcase).
      reject { |i| i.length < 2 }
    words -= STOPWORDS
    bigrams = words.each_cons(2).to_a
    trigrams = words.each_cons(3).to_a
    quadrograms = words.each_cons(4).to_a

    all_words = words + bigrams.map { |j| j.join(' ') } + trigrams.map { |j| j.join(' ') } + quadrograms.map { |j| j.join(' ') }
    all_words.reject! { |i| i.length < 5 || i.to_s[/^\d+$/] }
    all_words.reject! { |i| i.split(' ').all? { |j| STOPWORDS.include?(j) || j[/^\d+$/] } }
    all_words.uniq!
    trend_words = Trends::Word.where(word: all_words)
    insert_statements = []
    trend_words.each do |tw|
      all_words.delete(tw.word)
      next if tw.ignore?
      insert_statements << {
        usage_type: usage_type,
        dupe: @news_item.dupe_of_id.present?,
        news_item_id: @news_item.id,
        source_id: @news_item.source_id,
        word_id: tw.id,
        calendar_week: @calendar_week,
        date: @news_item.published_at
      }
    end
    all_words.each do |word|
      tw = Trends::Word.create(word: word, ignore: false)
      insert_statements << {
        usage_type: usage_type,
        dupe: @news_item.dupe_of_id.present?,
        news_item_id: @news_item.id,
        source_id: @news_item.source_id,
        word_id: tw.id,
        calendar_week: @calendar_week,
        date: @news_item.published_at
      }
    end
    Trends::Usage.insert_all(insert_statements) if insert_statements.any?
  end
end
