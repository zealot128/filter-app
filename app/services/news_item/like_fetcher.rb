class NewsItem::LikeFetcher
  attr_reader :url, :eurl
  def initialize(url)
    @url = url
    @eurl = CGI.escape(url)
  end

  def self.fetch_for_news_item(news_item)
    fetcher = new(news_item.url)
    news_item.retweets = fetcher.tweets
    f = fetcher.facebook
    if f
      news_item.fb_likes = f
    else
      news_item.fb_likes ||= 0
    end
    news_item.linkedin = fetcher.linkedin
    news_item.xing   = fetcher.xing
    news_item.gplus  = fetcher.gplus
    news_item.reddit = fetcher.reddit
  end

  def tweets
    json = JSON.parse Fetcher.fetch_url(
      "http://urls.api.twitter.com/1/urls/count.json?url=#{eurl}").body
    json['count']
  end

  def facebook
    # json = JSON.parse Fetcher.fetch_url(
    #   "https://api.facebook.com/method/fql.query?query=select%20%20url,like_count,%20total_count,%20share_count,%20click_count%20from%20link_stat%20where%20url%20=%20%22#{eurl}%22&format=json").body
    # json[0]["total_count"]
  # rescue
    body = Fetcher.fetch_url "https://www.facebook.com/v2.3/plugins/like.php?action=recommend&app_id=113869198637480&channel=https%3A%2F%2Fs-static.ak.facebook.com%2Fconnect%2Fxd_arbiter%2F44OwK74u0Ie.js%3Fversion%3D41%23cb%3Df232c6343e45cbe%26domain%3Ddevelopers.facebook.com%26origin%3Dhttps%253A%252F%252Fdevelopers.facebook.com%252Ff29ef60e417f34%26relation%3Dparent.parent&container_width=588&href=#{eurl}&locale=de_DE&sdk=joey&share=true&show_faces=true"
    return nil if body.code == 503
    body.body.to_s[/(\d+) Person(en)? empfehlen das/, 1].to_i
  end

  def linkedin
    body = Fetcher.fetch_url("http://www.linkedin.com/countserv/count/share?url=#{eurl}&lang=en_US").body
    body[/.count.:(\d+)/, 1].to_i
  end

  def xing
    response = Fetcher.fetch_url("https://www.xing-share.com/app/share?op=get_share_button;url=#{eurl};counter=right;lang=de;type=iframe;hovercard_position=1;shape=rectangle")
    doc = Nokogiri.parse(response.body)
    doc.at(".xing-count").text.to_i
  end

  def reddit
    response = Fetcher.fetch_url("http://buttons.reddit.com/button_info.json?url=#{eurl}")
    json = JSON.load response.body
    json['data']['children'].map { |i| i['data']['score'] }.sum
  end

  def gplus
    Nokogiri.parse(Fetcher.fetch_url("https://plusone.google.com/u/0/_/+1/fastbutton?url=#{eurl}").body).at("#aggregateCount").text.to_i
  end
end
