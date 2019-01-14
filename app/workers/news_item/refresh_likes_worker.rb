class NewsItem::RefreshLikesWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reschedule, unique_args: ->(_args) { 1 }, queue: 'low'

  def perform(news_item_id)
    news_item = NewsItem.find(news_item_id)
    news_item.refresh
    NewsItem::RefreshStatsWorker.perform_async(news_item.id)
  end
end
