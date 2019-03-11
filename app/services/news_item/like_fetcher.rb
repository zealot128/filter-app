class NewsItem::LikeFetcher
  attr_reader :url, :eurl
  def initialize(url)
    @url = url
    @eurl = CGI.escape(url)
  end

  def self.fetch_for_news_item(news_item)
    fetcher = new(news_item.url)

    fetcher.maybe_update_tweets(news_item)
    f = fetcher.facebook
    if f
      news_item.fb_likes = f
    else
      news_item.fb_likes ||= 0
    end
    news_item.linkedin = fetcher.linkedin
    news_item.xing   = fetcher.xing || 0
    news_item.gplus  = 0
    news_item.reddit ||= 3
  end

  def maybe_update_tweets(news_item)
    tweet_count = news_item.retweets ||= 0
    # search api returns bull anyway for old results
    return if news_item.created_at && news_item.created_at < 7.days.ago

    # last time it was 0 tweets, so only 50% chance of performing search again
    if news_item.retweets and news_item.retweets_was == 0
      return if rand < 0.5
    end

    # only update tweet count if it grows
    new_tweets = twitter_search(url).count
    if new_tweets > tweet_count
      news_item.retweets = new_tweets
    end
  rescue Twitter::Error::TooManyRequests
    nil
  rescue Twitter::Error::BadRequest => e
    return nil if Rails.env.development? || Rails.env.test?
    raise e
  rescue Twitter::Error::Forbidden => e
    NOTIFY_EXCEPTION(e)
  end

  def facebook
    body = Fetcher.fetch_url "https://www.facebook.com/v2.3/plugins/like.php?action=recommend&app_id=113869198637480&channel=https%3A%2F%2Fs-static.ak.facebook.com%2Fconnect%2Fxd_arbiter%2F44OwK74u0Ie.js%3Fversion%3D41%23cb%3Df232c6343e45cbe%26domain%3Ddevelopers.facebook.com%26origin%3Dhttps%253A%252F%252Fdevelopers.facebook.com%252Ff29ef60e417f34%26relation%3Dparent.parent&container_width=588&href=#{eurl}&locale=de_DE&sdk=joey&share=true&show_faces=true"
    return nil if body.code == 505
    body.body.to_s[/(\d+) Person(en)? empfehlen das/, 1].to_i
  end

  def linkedin
    body = Fetcher.fetch_url("https://www.linkedin.com/countserv/count/share?url=#{eurl}&lang=en_US").body
    body[/.count.:(\d+)/, 1].to_i
  end

  def xing
    response = Fetcher.fetch_url(
      "https://www.xing-share.com/app/share?op=get_share_button;url=#{eurl};counter=right;lang=de;type=iframe;hovercard_position=1;shape=rectangle"
    )
    doc = Nokogiri.parse(response.body)
    element = doc.at(".xing-count")
    element.text.to_i if element
  end

  private

  def twitter_search(str)
    TwitterSource.client.search(str)
  end
end
