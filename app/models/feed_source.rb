class FeedSource < Source
  validates_uniqueness_of :url
  def refresh
    old = news_items.pluck :id
    puts url
    entries = Feedzirra::Feed.fetch_and_parse(url).entries
    entries.map do |entry|
      item = NewsItem.process(
        title: entry.title,
        url: entry.url,
        text: entry.content,
        published: entry.published,
        guid: entry.entry_id || entry.url,
        source: self
      )
      old.delete item.id
    end
    old.map{|i|NewsItem.find(i).destroy}
    true
  end
end
