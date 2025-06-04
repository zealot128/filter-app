class LogoFinder
  attr_reader :source
  attr_reader :m
  def initialize(source)
    @source = source
    @m = Mechanize.new
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
    url = source.news_items.order('created_at desc').first&.url || URI.parse(source.url).tap { |i|
                                                                     i.path = '/'
                                                                                                   i.query = nil
    }.to_s
    m.get(url)
    imgs = m.page.search('img').pluck('src')
    imgs += m.page.search('[style*=background]').filter_map { |i| i['style'][/url\("?'?([^)"']+)"?'?\)/, 1] }.map(&:strip)

    m.page.search('link[rel][type=text\/css]').pluck('href').each do |css|
      imgs += extract_background_images_from_css(css)
    end
    imgs = imgs.map { |i|
             absolutize_url(i, url).strip
           }.uniq.reject { |i| i[/www.facebook.com|spinner|loader|gravatar|pin_it_button|www.twitter.com/] }
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

  def extract_background_images_from_css(file)
    m.get(file)
    parser = CssParser::Parser.new
    parser.load_string! m.page.body

    parser.each_selector.flat_map { |_, rules, _| rules.split(';').select { |i| i[/background.*url/] } }.compact_blank.filter_map { |rule|
      rule[/url\("?'?([^)"']+)"?'?\)/, 1]
    }.map { |url|
      absolutize_url(url, m.page.uri.to_s)
    }
  end
end
