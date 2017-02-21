class SourceSerializer < SourcePreviewSerializer
  attributes :remote_url
  belongs_to :default_category
  attribute :statistics

  def statistics
    {
      total_news_count: object.news_items.count,
      current_news_count: object.news_items.current.count,
      current_top_score: (object.news_items.current.maximum(:absolute_score) || 0).round,
      current_impression_count:  object.news_items.current.sum(:impression_count)
    }
  end
end
