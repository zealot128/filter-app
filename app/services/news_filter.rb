class NewsFilter
  include ActiveModel::Model
  attr_accessor :per_page
  attr_accessor :preferred
  attr_accessor :blacklisted
  attr_accessor :page

  def news_items
    @news_items = NewsItem.sorted.includes(:categories, :source).limit(@limit).page(@page)
    if @blacklisted.present?
      @news_items = @news_items.where.not(source_id: @blacklisted.split(',').map(&:to_i))
    end
    if @preferred.present?
      s = @preferred.split(',').map(&:to_i).join(',')
      @news_items = @news_items.visible.reorder!("value * (case when source_id in (#{s}) then 2 when true then 1 end)")
    end
    @news_items
  end
end
