require 'premailer/html_to_plain_text'
class LinkExtractor
  include HtmlToPlainText
  ARTICLE_RULES = %w[
    .entry-content
    .post-content
    #main-content
    #main\ .content
    #articleContent
    .node-content
    .transcript
    #articleContent
    [itemprop=articleBody]
    .articleBody
    .postContent
    .hcf-content
    .entryContent
    .post-entry
    .content
    .post
    .entry
    .article-content
    .article
  ].freeze

  RULES = %w[
    main
    section
    article
    #content
    .content
  ].freeze

  def self.run(url, close_connection: true)
    rf = new(site_name: Setting.site_name)

    if rf.run(url, close_connection:)
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

  def run(url, close_connection: true, &block)
    @m.get(url.to_s)
    if @m.page.is_a?(Mechanize::Image)
      @image_url = url
      return false
    end
    unless @m.page.respond_to?(:at)
      return false
    end
    if successful?
      if block_given?
        yield(result)
      else
        result
      end
    end
  rescue Mechanize::ResponseCodeError, Mechanize::RedirectLimitReachedError
    false
  ensure
    shutdown! if close_connection
  end

  def result
    {
      title:,
      teaser:,
      image_url:,
      full_text:,
      clean_url:,
      has_paywall: paywall?
    }
  end

  def teaser
    @teaser ||=
      @m.page.parser.xpath('//meta[@property="og:description"]').first&.[]('content') ||
      @m.page.parser.xpath('//meta[@name="description"]').first&.[]('content') ||
      begin
        stripped = ActionController::Base.helpers.strip_tags(full_text)
        ActionController::Base.helpers.truncate(stripped, length: 400, separator: ' ', escape: false)
      end
  end

  def successful?
    @m.page.code.to_i == 200 && !clean_url['/404(.html)?']
  end

  def image_url
    @image_url ||= begin
                     image = @m.page.parser.xpath('//meta[@property="og:image" or @name="shareaholic:image"]').first
                     image ||= @m.page.parser.xpath('//link[@rel="image_src"]').first
                     image['content'] || image['href'] if image
    end
  end

  def paywall?
    return @_paywall if @_paywall != nil

    @_paywall = self.class.paywall?(@m.page)
  end

  def self.paywall?(doc)
    lds = doc.search('script[type="application\/ld+json"]')

    lds.each do |ld|
      json = JSON.parse(ld.inner_html)
      json = [json] unless json.is_a?(Array)
      json.each do |ld|
        if ld['isAccessibleForFree'].to_s.downcase == 'false' # Handelsblatt macht "False"
          return true
        end
      end
    rescue JSON::ParserError
      next
    end
    false
  end

  def image_blob
    return nil unless image_url

    @image_blob ||= download_url(image_url)
  rescue SocketError, StandardError => e
    Rails.logger.error "image download failed: #{image_url}: #{e.inspect}"
    nil
  end

  def full_text
    return @full_text if @full_text
    return unless @m.page.respond_to?(:search)

    if (html = @m.page.search(ARTICLE_RULES.join(', ')).max_by { |f| f.text.gsub(/\s+/, ' ').strip.length })
      @full_text = clear(html.to_s)
    elsif (html = @m.page.search(RULES.join(', ')).max_by { |f| f.text.gsub(/\s+/, ' ').strip.length })
      @full_text = clear(html.to_s)
    end
  end

  def title
    @title ||=
      @m.page.parser.xpath('//meta[@property="og:title"]').first&.[]('content') ||
      @m.page.title
  end

  def clean_url
    @clean_url ||= @m.page.uri.to_s.gsub(/&?utm_(medium|campaign|source|term|content)=[^&]+/, '').remove(/\?$/)
  end

  private

  def clear(text)
    doc = Nokogiri::HTML.fragment(text)
    doc.search('script, form, style, #ad, div.ad, .social, aside.tools, footer, .sr-only, .share-buttons, .shariff, .meta-one').each(&:remove)
    doc.search('a[href*="facebook.com/shar"], a[href*="twitter.com/intent"]').each(&:remove)
    s = doc.to_s.gsub(/\s+/, ' ')
    sanitize s, attributes: %w(href src), tags: %w[li ul strong b i em ol br p a img]
  end

  def sanitize(*)
    ActionController::Base.helpers.sanitize(*)
  end

  def download_url(url)
    url = URI::DEFAULT_PARSER.escape(url).gsub(" ", "%20")
    io = URI.open(url)
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
