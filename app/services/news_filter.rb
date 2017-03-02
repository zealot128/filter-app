class NewsFilter
  include ActiveModel::Model
  attr_accessor :per_page
  attr_accessor :preferred
  attr_accessor :blacklisted
  attr_accessor :page
  attr_accessor :categories
  attr_accessor :order

  def news_items
    @news_items = NewsItem.sorted.includes(:categories, :source).limit(@limit).page(@page)
    apply_filter!
    apply_order!
    @news_items
  end

  def apply_order!
    if order == 'best'
      @news_items = @news_items.visible.top_percent_per_day(14.days.ago, 0.3334, 8)
    else #hot_score
      ranking = "news_items.absolute_score_per_halflife + (log(news_items.absolute_score) *  #{boost}) "
      @news_items = @news_items.visible.select("news_items.*, #{ranking} as current_score")
      @news_items = @news_items.reorder!('current_score desc')
    end
  end

  def apply_filter!
    if @blacklisted.present?
      @news_items = @news_items.where.not(source_id: escape(@blacklisted))
    end
    if @categories.present?
      @news_items = @news_items.where(%{news_items.id in (
                                      select news_item_id from categories_news_items
                                      where news_item_id = news_items.id and
                                            category_id in (#{escape(@categories).join(',')})
                                      )})
    end
  end

  def boost
    if @preferred.present?
      s = @preferred.split(',').map(&:to_i).join(',')
      "case when source_id in (#{s}) then 5 when true then 0 end"
    else
      '0'
    end
  end

  def escape(string_array)
    string_array.split(',').map(&:to_i)
  end
end
