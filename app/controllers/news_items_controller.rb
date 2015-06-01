class NewsItemsController < ApplicationController
  def index
    if params[:q].present?
      @news_items = NewsItem.search_full_text(params[:q]).paginate(page: params[:page])
    end
  end
end
