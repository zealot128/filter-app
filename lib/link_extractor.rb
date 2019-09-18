class LinkExtractor
  RULES = %w[
    .entry-content
    .post-content
    #main-content
    #main\ .content
    #articleContent
    .node-content
    .transcript
    #articleContent
    #content
    [itemprop=articleBody]
    .articleBody
    .postContent
    .hcf-content
    .entryContent
    .post-entry
    .content
    .post
    .entry
    article
    .article
    main
    section
  ].freeze

  def self.run(url, close_connection: true)
    rf = new(site_name: Setting.site_name)

    if rf.run(close_connection: close_connection)
      rf
    end
  end

  def initialize(site_name:)
    @m = Mechanize.new
    @m.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @m.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0 #{site_name}) Gecko/20100101 Firefox/70.0"
    @m.open_timeout = 15
    @m.read_timeout = 15
  end

  def shutdown!
    @m.shutdown
  end

  def run(url, close_connection: true)
    @m.get(url.to_s)

    shutdown! if close_connection
    successful?
  end

  def successful?
    binding.pry
  end

  def image_url
    @image_url ||= begin
                     image = page.parser.xpath('//meta[@property="og:image" or @name="shareaholic:image"]').first || page.parser.xpath('//link[@rel="image_src"]').first
                     image['content'] || image['href'] if image
                   end
  end

  def image_blob
    return nil unless image_url

    @image_blob ||= download_url(url)
  rescue SocketError, StandardError => e
    Rails.logger.error "image download failed: #{url}: #{e.inspect}"
    nil
  end

  def full_text
    return @full_text if @full_text

    if (html = page.search(RULES.join(', ')).max_by { |f| f.text.gsub(/\s+/, ' ').strip.length })
      @full_text = clear(html.to_s)
    end
  end

  def title
    @m.page.title
  end

  def clean_url
    @m.page.uri.to_s.gsub(/&?utm_(medium|campaign|source)=[^&]+/, '')
  end

  private

  def clear(text)
    doc = Nokogiri::HTML.fragment(text)
    doc.search('script, form, style, #ad, div.ad, .social, aside.tools, footer').each(&:remove)
    doc.search('a[href*="facebook.com/shar"], a[href*="twitter.com/intent"]').each(&:remove)
    s = doc.to_s.gsub(/\s+/, ' ')
    sanitize s, attributes: %w(href src), tags: %w[li ul strong b i em ol br p a img]
  end

  def sanitize(*args)
    ActionController::Base.helpers.sanitize(*args)
  end

  def download_url(url)
    url = URI.escape(url)
    url.gsub!(" ", "%20")
    io = Kernel.open(url)
    logo_path = url.split("/").last
    if logo_path.length > 50
      logo_path = "preview.#{logo_path[/(jpg|png)/i, 1] || 'jpg'}"
    end
    io.define_singleton_method(:original_filename) do
      logo_path
    end
    io
  rescue OpenURI::HTTPError => e
    Rails.logger.error "#{url} not found: #{e.inspect}"
    nil
  end
end
