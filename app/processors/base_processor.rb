class BaseProcessor
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
  class << self
    attr_accessor :host, :full_text_selector
  end

  def self.inherited(base)
    @@classes ||= []
    @@classes << base
  end

  def self.process(source)
    default = FeedProcessor
    host = URI.parse(source.url).host
    delegated = @@classes.find do |klass|
      klass.host == host
    end || default
    delegated.new.process(source)
  end

  def teaser(text)
    return "" if text.blank?

    stripped = ActionController::Base.helpers.strip_tags(text).strip
    ActionController::Base.helpers.truncate(stripped, length: 400, separator: ' ', escape: false)
  end

  def sanitize(*args)
    ActionController::Base.helpers.sanitize(*args)
  end

  def clear(text)
    doc = Nokogiri::HTML.fragment(text)
    doc.search('script, form, style, #ad, div.ad, .social, aside.tools, footer').each(&:remove)
    doc.search('a[href*="facebook.com/shar"], a[href*="twitter.com/intent"]').each(&:remove)
    s = doc.to_s.gsub(/\s+/, ' ')
    sanitize s, attributes: %w(href src), tags: %w[li ul strong b i em ol br p a img]
  end

  def get(url)
    @m ||= Mechanize.new
    @m.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @m.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0 #{Setting.site_name}) Gecko/20100101 Firefox/57.0"
    @m.open_timeout   = 15
    @m.read_timeout   = 15
    @m.get(url)
  end

  def clean_connection!
    @m.shutdown if @m
    @m = nil
  end
end
