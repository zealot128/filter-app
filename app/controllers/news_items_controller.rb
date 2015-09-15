class NewsItemsController < ApplicationController

  def index
    minscore = 0.5
    if params[:q].present?
      @feed_url = search_url(q: params[:q], sort: params[:sort], format: :rss)
      @news_items = NewsItem.
        where('published_at > ?', 2.years.ago).
        includes(:source, :categories).
        search_full_text(params[:q]).
        where('pg_search_news_items.rank > ?', minscore)
      case params[:sort]
      when 'freshness'
        @news_items = @news_items.reorder('published_at desc')
      when 'score'
        @news_items = @news_items.reorder('absolute_score desc')
      end

      respond_to do |f|
        f.html {
          @news_items = @news_items.paginate(page: params[:page], per_page: 40)
        }
        f.rss {
          @news_items = @news_items.limit(50)
        }
      end
    end
  end

  def show
    news_item = NewsItem.find(params[:id])
    # @current_user = ...
    impressionist(news_item)
    redirect_to news_item.url
  end

  def homepage
    @news_items = NewsItem.home_page.limit(36).page(params[:page])
    if params[:category].present?
      if params[:category].to_i == 0
        @news_items = @news_items.joins('LEFT JOIN "categories_news_items" ON "categories_news_items"."news_item_id" = "news_items"."id"').
          where('news_item_id is null').
          group('news_items.id')
      else
        @news_items =
          @news_items.joins(:categories).where(categories: { id: params[:category] }).group('news_items.id')
      end
    end
    render json: {
      html: render_to_string('homepage.html', layout: false),
      pagination: {
        total_pages: @news_items.total_pages,
        total_entries: @news_items.total_entries
      }
    }
  end
end
