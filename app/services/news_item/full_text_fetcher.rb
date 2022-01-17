require 'link_extractor'
class NewsItem::FullTextFetcher
  def initialize(news_item, unknown_selector: false)
    @news_item = news_item
    @source = news_item.source
    @processor = FeedProcessor.new
    @unknown_selector = unknown_selector
  end

  def selector
    @source.full_text_selector.presence || (@unknown_selector ? BaseProcessor::RULES.join(',') : false)
  end

  attr_reader :page

  def run
    return unless selector

    @page = @processor.get(@news_item.url)
    page = @page
    return unless page.respond_to?(:at)

    @news_item.url = page.uri.to_s.gsub(/\?utm_source.*/, "")
    @news_item.embeddable = page.response.keys.map(&:downcase).exclude?('x-frame-options')
    content = page.at(selector)
    if content
      content.search('script, style, .dd_post_share, .dd_button_v, .dd_button_extra_v, #respond').remove
      @news_item.full_text = @processor.clear content.inner_html
    end
    if @news_item.teaser.blank?
      @news_item.teaser = @processor.teaser(@news_item.full_text)
    end
    if @news_item.title.blank?
      @news_item.title = page.at('title').try(:text)
    end
    @news_item.paywall = ::LinkExtractor.paywall?(@page)
    NewsItem::ImageFetcher.new(@news_item, page).run if @news_item.persisted?
    NewsItem::AnalyseTrendWorker.perform_async(@news_item.id) if @news_item.persisted?
  rescue Mechanize::ResponseCodeError, Timeout::Error, SocketError, Mechanize::RedirectLimitReachedError, Nokogiri::CSS::SyntaxError => e
    Rails.logger.error "Error fetching #{@news_item.url} (#{@news_item.id}): #{e.inspect}"
  ensure
    @processor.clean_connection!
  end
end
