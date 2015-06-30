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
      klass.host ==host
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
end

