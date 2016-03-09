class FeedSource < Source
  validates_uniqueness_of :url
  validates :twitter_account, format: { with: %r{\A([a-zA-Z](_?[a-zA-Z0-9]+)*_?|_([a-zA-Z0-9]+_?)*)\z} }, if: :twitter_account?

  def should_fetch_stats?(ni)
    true
  end

  def refresh
    Processor.process(self)
    # old.map{|i|NewsItem.find(i).destroy}
    true
  end
end
