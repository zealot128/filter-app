class NewsItem::RefreshStatsJob < ApplicationJob
  def perform(news_item_id)
    news_item = NewsItem.find(news_item_id)
    news_item.get_full_text
    news_item.filter_plaintext
    news_item.blacklist
    news_item.categorize
    NewsItem::LinkageCalculator.new(news_item).run
    news_item.rescore!
  end
end
