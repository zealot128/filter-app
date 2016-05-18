class ApiController < ApplicationController
  before_action do
    if params[:api_key] != Rails.application.secrets.api_key
      render json: {status: :error, message: 'Unauthorized Access'}, status: :unauthorized
    end
  end

  def news_items(category: "0", order: "recent")
    @news_items = NewsItem.visible
    if category.present?
      case category.to_i
      when 0
        @news_items = @news_items.uncategorized
      when -1
        @news_items = @news_items
      else
        @news_items = @news_items.joins(:categories).where(categories: { id: category }).group('news_items.id')
      end
    end
    case order
    when 'recent'
      @news_items = @news_items.reorder('published_at desc')
    when 'score'
      @news_items = @news_items.reorder('absolute_score desc')
    end
    render json: {
      news_items: @news_items
    }
  end

end
