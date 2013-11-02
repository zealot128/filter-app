class FeedSource < Source
  validates_uniqueness_of :url
  def refresh
    Processor.process(self)
    # old.map{|i|NewsItem.find(i).destroy}
    true
  end
end


