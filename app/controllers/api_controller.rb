class ApiController < ApplicationController
  before_action do
    if params[:api_key] != Rails.application.secrets.api_key
      render json: {status: :error, message: 'Unauthorized Access'}, status: :unauthorized
    end
  end

  def news_items
    @news_items = NewsItem.visible
    if params[:category].present?
      case params[:category].to_i
      when 0
        @news_items = @news_items.uncategorized
      when -1
        @news_items = @news_items
      else
        @news_items = @news_items.joins(:categories).where(categories: { id: params[:category] }).group('news_items.id')
      end
    end
    case params[:order]
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
