class NewsFilter
  include ActiveModel::Model
  attr_accessor :per_page
  attr_accessor :preferred
  attr_accessor :blacklisted
  attr_accessor :page
  attr_accessor :categories
  attr_accessor :order

  def news_items
    @news_items = NewsItem.sorted.includes(:categories, :source).limit(@per_page).page(@page)
    apply_filter!
    apply_order!
    @news_items
  end

  def apply_order!
    if order == 'all_best'
      @news_items = @news_items.visible.reorder!('absolute_score desc')
    elsif order == 'best'
      @news_items = @news_items.visible.top_percent_per_day(4.weeks.ago, 0.3334, 8).reorder!('published_at::date desc, absolute_score desc')
    elsif order == 'newest'
      @news_items = @news_items.visible.reorder!('published_at desc')
    elsif order == 'oldest'
      @news_items = @news_items.visible.reorder!('published_at asc')
    elsif order == 'week_best'
      @news_items = @news_items.visible.top_percent_per_week(8.weeks.ago, 0.3334, 15).reorder!("to_char(published_at, 'IW/IYYY') desc, absolute_score desc")
    elsif order == 'month_best'
      @news_items = @news_items.visible.top_percent_per_month(6.months.ago, 0.3334, 30).reorder!("to_char(published_at, 'MM/YYYY') desc, absolute_score desc")
    else # hot_score
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
