module Newsletter
  class CategorySection
    attr_accessor :category, :news_items

    def initialize(category, mailing)
      @category = category
      @mailing = mailing
      load_news_items
    end

    def to_partial_path
      "newsletter_mailer/category_section"
    end

    def title = category.name

    def toc_title = "#{title} <small>(#{@news_items.count} Beiträge)</small>"

    def anchor = "category-#{category.id}"

    protected

    def load_news_items
      @news_items = all_items.
        group('news_items.id').
        order('absolute_score desc').
        where('published_at > ? and published_at <= ?', *@mailing.interval)
    end

    def all_items
      if category.is_a?(Uncategorized)
        NewsItem.uncategorized
      else
        NewsItem.
          joins(:categories).
          where(categories: { id: category })
      end
    end
  end
end
