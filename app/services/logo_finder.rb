class LogoFinder
  attr_reader :source
  def initialize(source)
    @source = source
  end

  def run
    case source
    when FeedSource
      feed_source
    else
      raise NotImplementedError
    end
  end

  def feed_source
    url = source.news_items.order('created_at desc').first&.url || URI.parse(source.url).tap { |i| i.path = '/'; i.query = nil }.to_s
    m = Mechanize.new
    m.get(url)
    imgs = m.page.search('img').map { |i| i['src'] }
    imgs += m.page.search('[style*=background]').map { |i| i['style'][/url\("?'?([^)"']+)"?'?\)/, 1] }.compact.map(&:strip)
    imgs = imgs.map { |i| absolutize_url(i, url) }
    source.image_candidates = imgs
    source.save
    # TODO: Alle Images url absoluten
  ensure
    m.shutdown if m
  end

  def absolutize_url(url, base)
    # next unless url
    if url.starts_with?('//')
      url = "https:#{url}"
    end
    unless url[%r{^http/}]
      url = URI.join(base, url).to_s
    end
    url
  end
end
