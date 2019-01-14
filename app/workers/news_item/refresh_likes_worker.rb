class NewsItem::RefreshLikesWorker
  include Sidekiq::Worker

  def perform(news_item_id)
    news_item = Newsitem.find(news_item_id)
    news_item.refresh
    NewsItem::RefreshStatsWorker.perform_async(ni.id)
  end
end
