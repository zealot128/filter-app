class NewsFilter
  include ActiveModel::Model
  attr_accessor :query
  attr_accessor :per_page
  attr_accessor :preferred
  attr_accessor :blacklisted
  attr_accessor :page
  attr_accessor :teaser_enabled
  attr_accessor :image_exists
  attr_accessor :categories
  attr_accessor :order
  attr_accessor :from
  attr_accessor :to
  attr_accessor :trend
  attr_accessor :media_type

  def news_items
    @news_items = NewsItem.sorted.visible.includes(:categories, :source).limit(@per_page).page(@page)
    if (id = Setting.get('promoted_feed_id')).present?
      @news_items = @news_items.where.not(source_id: id)
    end
    if (ids = Setting.get('hide_feed_id_from_homepage'))
      @news_items = @news_items.where.not(source_id: ids)
    end

    apply_filter!
    apply_order!
    @news_items
  end

    def apply_order!
    case order
    when 'all_best'
      @news_items = @news_items.reorder!(Arel.sql('absolute_score desc, published_at desc, news_items.id'))
    when 'best'
      @news_items = @news_items.
        top_percent_per_day(6.months.ago, 0.3334, 8).
        reorder!(Arel.sql('published_at::date desc, absolute_score desc, published_at desc, news_items.id'))
    when 'newest'
      @news_items = @news_items.reorder!('published_at desc, id desc')
    when 'oldest'
      @news_items = @news_items.reorder!('published_at asc, id desc')
    when 'week_best'
      @news_items = @news_items.
        top_percent_per_week(6.months.ago, 0.3334, 15).
        reorder!(Arel.sql("to_char(published_at, 'IW/IYYY') desc, absolute_score desc, news_items.id"))
    when 'month_best'
      @news_items = @news_items.
        top_percent_per_month(6.months.ago, 0.3334, 30).
        reorder!(Arel.sql("to_char(published_at, 'MM/YYYY') desc, absolute_score desc, news_items.id"))
    else # hot_score
      ranking = "news_items.absolute_score_per_halflife + (log(news_items.absolute_score) *  #{boost}) "
      @news_items = @news_items.visible.select("news_items.*, #{ranking} as current_score")
      @news_items = @news_items.reorder!('current_score desc, id desc')
    end
    end

  def apply_filter!
    if @blacklisted.present?
      @news_items = @news_items.where.not(source_id: escape(@blacklisted))
    end
    if teaser_enabled.present?
      @news_items = @news_items.where(source_id: Source.lsr_allowed)
    end
    if image_exists.present?
      @news_items = @news_items.where.not(image_file_name: nil)
    end
    if @categories.present?
      @news_items = @news_items.where(%{news_items.id in (
                                      select news_item_id from categories_news_items
                                      where news_item_id = news_items.id and
                                            category_id in (#{escape(@categories).join(',')})
                                      )})
    end
    if @trend.present?
      trends = Trends::Trend.where(slug: @trend.split(','))
      @news_items = @news_items.where(id: Trends::Word.where(trend_id: trends).joins(:usages).select('news_item_id'))
    end
    if @from.present?
      from = Time.zone.parse(@from).to_date
      @news_items = @news_items.where('published_at::date >= ?', from)
    end
    if @to.present?
      to = Time.zone.parse(@to).to_date
      @news_items = @news_items.where('published_at::date <= ?', to + 1)
    end
    if @query.present?
      @news_items = @news_items.
        search_full_text(@query).
        with_pg_search_rank.where('rank > ?', 0)
    end
    if @media_type.present?
      @news_items = @news_items.where(source_id: Source.where(type: @media_type.split(',')).uniq)
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
