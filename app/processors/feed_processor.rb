class FeedProcessor < Processor
  def process(source)
    @source = source

    feed = parse_feed(source.url)
    if !feed.respond_to?(:entries)
      source.update_column :error, true
      # TODO: Error reporting
    else
      source.update_column :error, false
      feed.entries.each do |entry|
        item = process_entry(entry)
        if item
          item.get_full_text
          item.save
        end
      end
    end
  end

  def log(message)
    puts message
  end

  def parse_feed(feed_url)
    # Import from Feedjra, because no Timeout support yet :(
    # https://github.com/feedjira/feedjira/issues/294
    connection = Faraday.new do |conn|
      conn.use FaradayMiddleware::FollowRedirects, limit: 3
      conn.adapter :net_http
      conn.options.timeout = 2000
      conn.options.open_timeout = 2000
    end
    response = connection.get(feed_url)
    xml = response.body
    if xml.nil?
      log "Feed Download fehlgeschlagen: #{feed_url}, kein Inhalt (Timeout?)"
      return
    end
    Feedjira::Feed.parse(xml)
  rescue Feedjira::NoParserAvailable
    log "Feed Download fehlgeschlagen: Kein Feed Format: #{feed_url}"
  rescue Feedjira::FetchFailure
    log "Download fehlgeschlagen: #{feed_url} -> #{response.status}"
  end

  def find_news_item(guid, url)
    guid = guid[0..230]
    old = @source.news_items.where(guid: guid).first
    old || @source.news_items.where(url: url).first ||
      @source.news_items.where("regexp_replace(news_items.url, '^https?:', '') = regexp_replace(:url, '^https?:', '')", url: url).first ||
      @source.news_items.build(guid: guid, url: url)
  end

  def process_entry(entry)
    @entry = entry
    title = entry.title
    url = entry.url
    text = entry.content || entry.summary
    published = entry.published
    guid = (entry.entry_id || entry.url)
    if url.starts_with?('//')
      url = "http:#{url}"
    end
    unless url[%r{^http|^/}]
      url = URI.join(@source.url, url).to_s
    end
    @item = find_news_item(guid, url)
    @item.url = url
    if @item.new_record?
      @item.source = @source
      @item.published_at = [Time.zone.now, published].min
    end
    @item.title = title if title.present?
    @item.teaser = teaser(text) if text.present?
    @item.save!
    if defined?(@entry.image) and @entry.image.present? and @item.image.blank?
      begin
        image = download_url(@entry.image)
        @item.update_attributes image: image
      rescue SocketError, StandardError => e
        Rails.logger.error "image download fehlgeschlagen #{url} #{e.inspect}"
      end

    end
    @item
  end
end
