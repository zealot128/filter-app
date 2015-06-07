class NewsItem::LikeFetcher
  attr_reader :url, :eurl
  def initialize(url)
    @url = url
    @eurl = CGI.escape(url)
  end

  def self.fetch_for_news_item(news_item)
    fetcher = new(news_item.url)
    news_item.retweets = fetcher.tweets
    news_item.fb_likes = fetcher.facebook
    news_item.linkedin = fetcher.linkedin
    news_item.xing     = fetcher.xing
    news_item.gplus    = fetcher.gplus
  end

  def tweets
    json = JSON.parse Fetcher.fetch_url(
      "http://urls.api.twitter.com/1/urls/count.json?url=#{eurl}").body
    json['count']
  end

  def facebook
    json = JSON.parse Fetcher.fetch_url(
      "https://api.facebook.com/method/fql.query?query=select%20%20url,like_count,%20total_count,%20share_count,%20click_count%20from%20link_stat%20where%20url%20=%20%22#{eurl}%22&format=json").body
    json[0]["total_count"]
  end

  def linkedin
    body = Fetcher.fetch_url("http://www.linkedin.com/countserv/count/share?url=#{eurl}&lang=en_US").body
    body[/.count.:(\d+)/, 1]
  end

  def xing
    response = Fetcher.fetch_url("https://www.xing-share.com/app/share?op=get_share_button;url=#{eurl};counter=right;lang=de;type=iframe;hovercard_position=1;shape=rectangle")
    doc = Nokogiri.parse(response.body)
    doc.at(".xing-count").text.to_i
  end

  def gplus
    Nokogiri.parse(Fetcher.fetch_url("https://plusone.google.com/u/0/_/+1/fastbutton?url=#{eurl}").body).at("#aggregateCount").text.to_i
  end
end
