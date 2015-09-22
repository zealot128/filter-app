class RedditSource < Source
  before_validation :set_url

  def refresh
    RedditProcessor.new.process(self)
  end

  def set_url
    self.url = "https://www.reddit.com/r/#{name}"
  end

  def download_thumb
    return if Rails.env.test?
    doc = Nokogiri.parse(open(host, redirect: true, allow_redirections: :all))
    img = doc.at('#header-img')
    return if img.blank? or img['src'].blank?
    logo_url = 'https:' + img['src']
    update_attributes logo: download_url(logo_url)
  end

  def should_fetch_stats?(ni)
    !ni.url.include?("www.reddit.com/r/#{name}")
  end
end
