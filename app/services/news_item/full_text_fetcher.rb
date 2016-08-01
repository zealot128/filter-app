class NewsItem::FullTextFetcher
  def initialize(news_item, unknown_selector: false)
    @news_item = news_item
    @source = news_item.source
    @processor = FeedProcessor.new
    @unknown_selector = unknown_selector
  end

  def selector
    @source.full_text_selector.presence || (@unknown_selector ? Processor::RULES.join(',') : false )
  end

  def run
    if selector
      begin
        page = @processor.get(@news_item.url)
        return unless page.respond_to?(:at)
        @news_item.url = page.uri.to_s.gsub(/\?utm_source.*/, "")
        content = page.at(selector)
        if content
          content.search('script, .dd_post_share, .dd_button_v, .dd_button_extra_v, #respond').remove
          @news_item.full_text = @processor.clear content.inner_html
        end
        NewsItem::ImageFetcher.new(@news_item, page).run
      rescue Mechanize::ResponseCodeError, SocketError
      end
    end
  end
end
