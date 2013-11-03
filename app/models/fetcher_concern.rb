module FetcherConcern
  extend ActiveSupport::Concern
  MAX_AGE ||= 14.days
  included do
    scope :old, -> { where("published_at < ?", (MAX_AGE + 1.day).ago) }
  end

  def score
    base = [ source.value, xing * 3, linkedin * 2, retweets, fb_likes / 2, gplus].reject(&:blank?).reduce(:+)
    time_factor = (published_at.to_i - MAX_AGE.ago.to_i) / (Time.now.to_i - MAX_AGE.ago.to_i).to_f
    base * time_factor
  end

  def eurl
    CGI.escape(url)
  end

  def fetch_twitter
    json = JSON.parse Fetcher.fetch_url(
      "http://urls.api.twitter.com/1/urls/count.json?url=#{eurl}").body
    self.retweets = json["count"]
  end

  def fetch_facebook
    json = JSON.parse Fetcher.fetch_url(
      "https://api.facebook.com/method/fql.query?query=select%20%20url,like_count,%20total_count,%20share_count,%20click_count%20from%20link_stat%20where%20url%20=%20%22#{eurl}%22&format=json").body
    self.fb_likes = json[0]["total_count"]
  end

  def fetch_linkedin
    body = Fetcher.fetch_url("http://www.linkedin.com/countserv/count/share?url=#{eurl}&lang=en_US").body
    self.linkedin = body[/.count.:(\d+)/, 1]
  end

  def fetch_xing
    response = Fetcher.fetch_url("https://www.xing-share.com/app/share?op=get_share_button;url=#{eurl};counter=right;lang=de;type=iframe;hovercard_position=1;shape=rectangle")
    doc = Nokogiri.parse(response.body)
    self.xing = doc.at(".xing-count").text.to_i
  end

  def fetch_gplus
    self.gplus = Nokogiri.parse(Fetcher.fetch_url("https://plusone.google.com/u/0/_/+1/fastbutton?url=#{eurl}").body).at("#aggregateCount").text.to_i
  end
end
