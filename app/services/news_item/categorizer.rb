class NewsItem::Categorizer
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
    categories = cats_with_matches.select { |_, count| count > 0 }.sort_by { |_, count| -count }.take(3).map { |c, _| c }
    @news_item.categories = categories
  end

  def text
    @text ||= (@news_item.plaintext + ' ' + @news_item.title).downcase
  end

  def self.run(ni)
    new(ni).run
  end
end
