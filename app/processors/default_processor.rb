class DefaultProcessor < Processor
  def process(source)
    @source = source
    feed = Feedjira::Feed.fetch_and_parse(source.url, max_redirects: 5, timeout: 30)
    if !feed.respond_to?(:entries)
      source.update_column :error, true
      puts "Feed download fehlgeschlagen: #{feed}"
      # TODO Error reporting
    else
      source.update_column :error, false
      feed.entries.each do |entry|
        process_entry(entry)
      end
    end
  end

  def news_item_by_guid(guid)
    guid = guid[0..230]
    old = @source.news_items.where(guid: guid).first
    old || NewsItem.new( guid: guid)
  end

  def process_entry(entry)
    @entry = entry
    title = entry.title
    url = entry.url
    text = entry.content || entry.summary
    published = entry.published
    guid = (entry.entry_id || entry.url)
    return if published < FetcherConcern::MAX_AGE.days.ago
    @item = news_item_by_guid(guid)
    @item.url ||= url
    if @item.new_record?
      @item.source = @source
      @item.published_at = published
    end
    follow_url(@item)
    @item.assign_attributes(
      teaser: teaser(text),
      title: title,
    )
    @item.save!
  end

  def follow_url(item)
    is_blank = item.full_text.blank?
    item.full_text = @entry.content || @entry.summary
    if is_blank
      item.get_full_text
    end
  end

end
