# :nocov:
class APIController < ApplicationController
  def news_items
    category = params["category"] || 0
    order = params["order"] || "recent"
    @news_items = NewsItem.visible.includes(:source, :categories)
    @news_items = case category.to_i
                  when 0
                    @news_items
                  else
                    @news_items.joins(:categories).where(categories: { id: category })
                  end
    case order
    when 'recent'
      @news_items = @news_items.reorder('published_at desc')
    when 'score'
      @news_items = @news_items.reorder('absolute_score desc')
    end
    render json: @news_items, status: :ok
  end

  def categories
    if params[:id]
      if category = grouped_categories.select { |cat| cat["id"] == params[:id].to_i }.first
        render json: category.to_json, status: :ok
      else
        render json: { status: :error, message: 'Not found' }, status: :not_found
      end
    else
      render json: grouped_categories, status: :ok
    end
  end

  private

  def grouped_categories
    grouped_categories ||= Category.joins(:categories_news_items).group("categories_news_items.category_id").count
    grouped_categories = grouped_categories.map do |id, count|
      category = Category.find(id)
      category.attributes.merge("news_items_count" => count)
    end
    grouped_categories
  end
end
