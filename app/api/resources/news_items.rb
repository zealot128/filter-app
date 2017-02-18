class Resources::NewsItems < Grape::API
  namespace :news_items do
    params do
      optional :to, Date
      optional :page, Integer, default: 1
      optional :limit, Integer, default: 30
    end
    get '/' do
      @news_items = NewsItem.news_items.limit(30).page(params[:page])
      render json: {
        news_items: @news_items.as_json(brief: true),
        pagination: {
          total_pages: @news_items.total_pages,
          total_entries: @news_items.total_entries
        }
      }
    end

  end

end

