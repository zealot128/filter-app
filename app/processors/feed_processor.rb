class FeedProcessor < BaseProcessor
  def process(source)
    @source = source
    feed = parse_feed(source.url)

    if feed.respond_to?(:entries)
      source.update_column :error, false
      feed.entries.each do |entry|
        item = process_entry(entry)
        next unless item
        item.new_record?
        item.save
        return if Rails.env.test?
      end
    else
      source.update_column :error, true
    end
  end

  def log(message)
    warn message unless Rails.env.production?
  end

  def parse_feed(feed_url)
    # Import from Feedjra, because no Timeout support yet :(
    # https://github.com/feedjira/feedjira/issues/294
    connection = Faraday.new do |conn|
      conn.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0 #{Setting.site_name}) Gecko/20100101 Firefox/57.0"
      conn.headers['Accept'] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      conn.use FaradayMiddleware::FollowRedirects, limit: 3
      conn.options.timeout = 60
      conn.adapter :typhoeus
    end
    response = connection.get(feed_url)
    xml = response.body
    if xml.nil?
      log "Feed Download fehlgeschlagen: #{feed_url}, kein Inhalt (Timeout?)"
      return
    end
    Feedjira.parse(xml)
  rescue Feedjira::NoParserAvailable
    log "Feed Download fehlgeschlagen: Kein Feed Format: #{feed_url}"
  rescue SystemCallError, Faraday::TimeoutError, Faraday::ClientError, URI::InvalidURIError
    log "Download fehlgeschlagen: #{feed_url} -> #{response.status}"
  end

  def find_news_item(guid, url, title)
    title = title[0...255]
    guid = guid[0..230]
    old = @source.news_items.where(guid:).first
    old || @source.news_items.where(url:).first ||
      @source.news_items.where("regexp_replace(news_items.url, '^https?:', '') = regexp_replace(:url, '^https?:', '')", url:).first ||
      (title && @source.news_items.where('created_at > ?', 3.months.ago).where(title:).first) ||
      @source.news_items.build(guid:, url:)
  end

  def process_entry(entry)
    @entry = entry
    title = entry.title.truncate(255)
    # binding.pry if title != entry.title
    url = entry.url&.strip
    text = entry.content || entry.summary
    published = entry.published
    guid = entry.entry_id || entry.url

    if !url and entry.entry_id and entry.entry_id.starts_with?('http')
      url = entry.entry_id
    end

    if defined? entry.enclosure_url
      media_url = entry.enclosure_url
      url ||= entry.enclosure_url
    end

    return unless url
    url.strip!

    # next unless url
    if url.starts_with?('//')
      url = "http:#{url}"
    end
    unless url[%r{^http/}]
      url = URI.join(@source.url, url).to_s
    end
    @item = find_news_item(guid, url, title)
    was_new = @item.new_record?
    @item.url = url
    unless media_url.nil?
      @item.media_url = media_url
    end
    if @item.new_record?
      @item.source = @source
      @item.published_at = [Time.zone.now, published].min
    end
    @item.title = title if title.present?
    @item.teaser = teaser(text) if text.present?
    if NewsItem::CheckFilterList.new(@source).skip_import?(title, text)
      @item.destroy if @item.persisted?
      return nil
    end
    @item.rescore!
    if defined?(@entry.image) and @entry.image.present? and @item.image.blank? and !@entry.image[/(mp3|aac|ogg|mp4|m4a|mov)$/i]
      begin
        image = download_url(@entry.image)
        @item.update image:
      rescue SocketError, StandardError => e
        Rails.logger.error "image download fehlgeschlagen #{url} #{e.inspect}"
      end
    end
    NewsItem::RefreshLikesJob.set(wait: 1.minute).perform_later(@item.id) if was_new
    @item
  end
end
