class NewsItemsController < ApplicationController
  def index
    if params[:q].present?
      @news_items = NewsItem.
        where('published_at > ?', 2.years.ago).
        search_full_text(params[:q]).paginate(page: params[:page])
    end
  end
end
