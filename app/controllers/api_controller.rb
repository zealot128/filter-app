class ApiController < ApplicationController
  before_action do
    if params[:api_key] != Rails.application.secrets.api_key
      render json: {status: :error, message: 'Unauthorized Access'}, status: :unauthorized
    end
  end

  def news_items
    category = params["category"] || 0
    order = params["order"] || "recent"
    @news_items = NewsItem.visible
    case category.to_i
    when 0
      @news_items = @news_items
    else
      @news_items = @news_items.joins(:categories).where(categories: { id: category })
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

  def category
    if params[:id] and category = grouped_categories.select{|cat| cat["id"] == params[:id]}.first
      render json: {status: :success, category: category.to_json}, status: 200
    else
      render json: {status: :error, message: 'Not found'}, status: 404
    end
  end

  def categories
    render json: {
      status: :success,
      categories: @grouped_categories.to_json
    }, status: 200
  end

  def grouped_categories
    grouped_categories ||= Category.joins(:categories_news_items).group("categories_news_items.category_id").count
    grouped_categories = grouped_categories.map do |id, count|
      category = Category.find(id)
      category.attributes.merge({"news_items_count" => count})
    end
    grouped_categories
  end
end
