class NewsItem::RefreshLikesJob < ApplicationJob
  queue_as :low
  limits_concurrency to: 1, key: ->(_news_item_id) { 1 }, duration: 20.seconds

  def perform(news_item_id)
    Timeout.timeout(30) do
      news_item = NewsItem.find(news_item_id)
      news_item.refresh
    end
  ensure
    NewsItem::RefreshStatsJob.perform_later(news_item_id)
  end
end
