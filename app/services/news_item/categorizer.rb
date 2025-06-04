class NewsItem::Categorizer
  MAX_CATEGORIES = 3

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    cats_with_matches = Category.all.map { |category|
      count = category.matching_keywords.sum { |kw| words.grep(kw).count }
      [category, count]
    }
    categories = cats_with_matches.select { |_, count| count > 0 }

    if ((default = @news_item.source.default_category)) && !categories.find { |cat, _| cat.id == default.id }
        categories << [default, 100_000]
    end

    categories = categories.sort_by { |_, count| -count }.take(MAX_CATEGORIES).map { |c, _| c }
    @news_item.categories = categories
  end

  def text
    @text ||= "#{@news_item.plaintext} #{@news_item.title}".downcase
  end

  def words
    @words ||= text.split(/[^\p{Word}]/) - [""]
  end

  def self.run(ni)
    new(ni).run
  end
end
