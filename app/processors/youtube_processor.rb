class YoutubeProcessor < FeedProcessor
  def parse_feed(url)
    doc = Nokogiri.parse(open(url))
    url = doc.at('link[rel=canonical]')['href']
    channel_id = url.split('/').last
    feed_url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
    super(feed_url)
  end

  def process_entry(entry)
    @entry = entry
    guid = entry.entry_id
    url = entry.url
    title = entry.media_title
    item = find_news_item(guid, url, title)
    item.url = url
    if item.new_record?
      item.source = @source
      item.published_at = [Time.zone.now, entry.published].min
    end
    item.full_text = entry.content
    item.title = entry.title
    item.teaser = teaser(item.full_text)

    if NewsItem::CheckFilterList.new(@source).skip_import?(title, item.full_text)
      item.destroy if item.persisted?
      return nil
    end
    item.youtube_likes = entry.media_star_count.to_i
    item.youtube_views = entry.media_views.to_i

    item.save!
    if defined?(entry.media_thumbnail_url) and entry.media_thumbnail_url.present? and item.image.blank?
      begin
        image = download_url(entry.media_thumbnail_url)
        item.update image: image
      rescue SocketError, StandardError => e
        Rails.logger.error "image download fehlgeschlagen #{url} #{e.inspect}"
      end
    end
    item
  end
end
