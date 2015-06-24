class FeedProcessor < Processor
  def process(source)
    @source = source
    feed = Feedjira::Feed.fetch_and_parse(source.url)
    if !feed.respond_to?(:entries)
      source.update_column :error, true
      puts "Feed download fehlgeschlagen: #{feed}"
      # TODO Error reporting
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
    @item = find_news_item(guid, url)
    @item.url ||= url
    if @item.new_record?
      @item.source = @source
      @item.published_at = published
    end
    @item.assign_attributes(
      teaser: teaser(text),
      title: title,
    )
    @item.save!
    @item
  end

end
