class NewsItem::RefreshStatsWorker
  include Sidekiq::Worker

  def perform(news_item_id)
    news_item = Newsitem.find(news_item_id)
    news_item.get_full_text
    news_item.blacklist
    news_item.categorize
    NewsItem::LinkageCalculator.new(news_item).run
    news_item.rescore!
  end
end
