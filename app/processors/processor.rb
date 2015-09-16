class Processor
  class << self
    attr_accessor :host, :full_text_selector
  end

  def self.inherited base
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
    ActionController::Base.helpers.truncate(
      ActionController::Base.helpers.strip_tags(text).strip,
      length: 400
    )
  end

  def sanitize(*args)
    ActionController::Base.helpers.sanitize(*args)
  end

  def clear(text)
    sanitize text, attributes: ['href','src'], tags: %w[li ul strong b i em ol br p a img]
  end

  def get(url)
    @m ||= Mechanize.new
    @m.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @m.user_agent = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
    @m.get(url)
  end

  def get_full_text_from_random_link(link)
    rules = %w[
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
      .postContent
      .hcf-content
      .entryContent
      .content
      .post
      .entry
      article
      .article
      main
      section
    ]
    res = get(link.to_s)
    if html = res.search(rules.join(', ')).find{|f| f.text.strip.length > 100 }
      clear html.to_s
    end
  rescue StandardError, Net::HTTPServiceUnavailable
    ""
  end
end

