class TwitterPosting
  def self.cronjob(interval: 2.days.ago)
    candidates = AdLogic.twitter_news(interval)

    candidates.select{|i| i.tweet_id.blank? }.take(1).each do |ni|
      new(ni).run
    end
  end

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    binding.pry
  end

  def tweet
    url = "https://www.hrfilter.de/ni/#{@news_item.id}"
    meta_data = "#{maybe_mention}#{maybe_hashtags}"
    length = 140 - 24 - 1 - meta_data.length
    title = @news_item.title.strip.truncate(length)
    "#{title} #{url}#{meta_data}"
  end

  def maybe_hashtags
    c = @news_item.categories.take(1).map{|i| "##{i.hash_tag}" }.join(' ')
    if c.present?
      c.prepend(" ")
    else
      c
    end
  end

  def maybe_mention
    @news_item.source.twitter_account ? " @#{@news_item.source.twitter_account}" : ""
  end
end
