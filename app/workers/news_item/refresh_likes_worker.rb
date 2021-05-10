class NewsItem::RefreshLikesWorker
  include Sidekiq::Worker

  # sidekiq_options lock: :while_executing, on_conflict: :reschedule, unique_args: ->(_args) { 1 }, queue: 'low'
  sidekiq_options queue: :low

  def perform(news_item_id)
    Timeout::timeout(30) do
      news_item = NewsItem.find(news_item_id)
      news_item.refresh
    end
  ensure
    NewsItem::RefreshStatsWorker.perform_async(news_item_id)
  end
end
