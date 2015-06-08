class NewsItemsController < ApplicationController
  def index
    if params[:q].present?
      @news_items = NewsItem.
        where('published_at > ?', 2.years.ago).
        search_full_text(params[:q]).paginate(page: params[:page])
    end
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
