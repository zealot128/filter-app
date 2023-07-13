class NewsItem::LikeFetcher
  attr_reader :url, :eurl
  def initialize(url)
    @url = url
    @eurl = CGI.escape(url)
  end

  def self.fetch_for_news_item(news_item)
    fetcher = new(news_item.url)

    f = fetcher.facebook
    if f
      news_item.fb_likes = f
    else
      news_item.fb_likes ||= 0
    end
    news_item.xing = fetcher.xing || 0
    news_item.reddit ||= 3
  end

  def facebook
    body = Fetcher.fetch_url "https://www.facebook.com/v2.3/plugins/like.php?action=recommend&app_id=113869198637480&channel=https%3A%2F%2Fs-static.ak.facebook.com%2Fconnect%2Fxd_arbiter%2F44OwK74u0Ie.js%3Fversion%3D41%23cb%3Df232c6343e45cbe%26domain%3Ddevelopers.facebook.com%26origin%3Dhttps%253A%252F%252Fdevelopers.facebook.com%252Ff29ef60e417f34%26relation%3Dparent.parent&container_width=588&href=#{eurl}&locale=de_DE&sdk=joey&share=true&show_faces=true"
    return nil if body.code == 505
    body.body.to_s[/(\d+) Person(en)? empfehlen das/, 1].to_i
  end

  def xing
    response = Fetcher.fetch_url(
      "https://www.xing-share.com/app/share?op=get_share_button;url=#{eurl};counter=right;lang=de;type=iframe;hovercard_position=1;shape=rectangle"
    )
    doc = Nokogiri.parse(response.body)
    element = doc.at(".xing-count")
    element.text.to_i if element
  end
end
