class NewsItemsController < ApplicationController
  def index
    if params[:q].present?
      @news_items = NewsItem.
        where('published_at > ?', 2.years.ago).
        search_full_text(params[:q]).paginate(page: params[:page])
    end
  end

  def homepage
    @news_items = NewsItem.home_page
    render json: {
      news_items: @news_items.map{|ni|
        {
          html: render_to_string(ni, formats: [:html])
        }
      }
    }
  end
end
