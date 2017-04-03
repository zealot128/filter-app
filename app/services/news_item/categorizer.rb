class NewsItem::Categorizer
  MAX_CATEGORIES = 3

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    cats_with_matches =
      Category.all.map do |category|
        matches = category.keywords.split(',').select do |kw|
          text.downcase[/(^|\W)#{Regexp.escape(kw.downcase)}($|\W)/]
        end
        [category, matches.count]
      end
    categories = cats_with_matches.select { |_, count| count > 0 }

    if default = @news_item.source.default_category
      unless categories.find { |cat, _| cat.id == default.id }
        categories << [default, 100000]
      end
    end

    categories = categories.sort_by { |_, count| -count }.take(MAX_CATEGORIES).map { |c, _| c }
    @news_item.categories = categories
  end

  def text
    @text ||= (@news_item.plaintext.to_s + ' ' + @news_item.title.to_s).downcase
  end

  def self.run(ni)
    new(ni).run
  end
end
