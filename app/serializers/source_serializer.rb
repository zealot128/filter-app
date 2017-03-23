class SourceSerializer < SourcePreviewSerializer
  attributes :remote_url, :top_categories
  belongs_to :default_category
  attribute :statistics
  type "source"
  def statistics
    {
      total_news_count: object.news_items.count,
      current_news_count: object.news_items.current.count,
      current_top_score: (object.news_items.current.maximum(:absolute_score) || 0).round,
      current_impression_count:  object.news_items.current.sum(:impression_count)
    }
  end

  def top_categories
    object.news_items.joins(:categories).
      group('categories.id').order('count_all desc').limit(3).count.to_a.map{|id, count| Category.find(id).as_json.merge(count: count) }
  end
end
