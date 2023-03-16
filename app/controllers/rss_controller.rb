class RssController < ApplicationController
  def index
  end

  def daily_top_10
    @news_items = news_items.top_percent_per_day(14.days.ago, 0.2, 10).order('published_at::date desc, absolute_score').limit(200)
    render 'feed', formats: [:rss]
  end

  def daily_top_50
    @news_items = news_items.top_percent_per_day(14.days.ago, 0.5, 30).order('published_at::date desc, absolute_score').limit(200)
    render 'feed', formats: [:rss]
  end

  def weekly_top_50
    @news_items = news_items.top_percent_per_week(4.weeks.ago, 0.2, 50).order(Arel.sql("to_char(published_at, 'YYYY/IW') desc, absolute_score desc")).limit(200)
    render 'feed', formats: [:rss]
  end

  def newest
    @news_items = news_items.order('published_at desc').limit(200)
    render 'feed', formats: [:rss]
  end

  private

  def news_items
    NewsItem.visible.includes(:source)
  end

  def description(news_item)
    if news_item.source.lsr_active?
      news_item.source.name
    else
      s = news_item.source.name
      if news_item.image.present?
        s += "<br><img src='#{root_url + news_item.image.url}'/>"
      end
      s + "<br><br>" + news_item.teaser.to_s
    end
  end
  helper_method :description
end
