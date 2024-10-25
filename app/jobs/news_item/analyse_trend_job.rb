class NewsItem::AnalyseTrendJob < ApplicationJob
  def perform(news_item_id)
    news_item = NewsItem.find(news_item_id)
    Trends::Processor.new(news_item).run
  end
end
