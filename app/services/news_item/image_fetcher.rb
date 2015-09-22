class NewsItem::ImageFetcher
  attr_reader :news_item, :page
  def initialize(news_item, page)
    @news_item = news_item
    @page = page
  end

  def run
    return if news_item.image.present?

    image = page.parser.xpath('//meta[@property="og:image" or @name="shareaholic:image"]').first || page.parser.xpath('//link[@rel="image_src"]').first
    if image
      url = image['content'] || image['href']
      begin
        image = download_url(url)
        news_item.update_attributes image: image
      rescue SocketError, StandardError => e
        Rails.logger.error "OG image download fehlgeschlagen #{url} #{e.inspect}"
      end
    end
  end
end
