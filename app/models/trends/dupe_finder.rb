class Trends::DupeFinder
  def self.cronjob(date_in_week: 1.day.ago)
    news_this_week = NewsItem.without_dupes.where(created_at: date_in_week.to_time.all_week)
    new(news_this_week).run
  end

  def initialize(news_items)
    @news_items = news_items
    @already_processed = []
  end

  def run
    if @news_items.is_a?(ActiveRecord::Relation)
      @news_items.find_each do |ni|
        check(ni)
      end
    else
      @news_items.each do
        check(ni)
      end
    end
  end

  def check(news_item)
    return if @already_processed.include?(news_item.id)
    return if news_item.plaintext.blank? || news_item.plaintext.length < 400

    words = news_item.trend_usages.select(:word_id)

    sql = Trends::Usage.where(word_id: words).
      where.not(news_item_id: news_item.id).
      group('news_item_id').
      having('count(*) > ?', (words.length * 0.5).round).
      count

    dupes = sql.keys
    return if dupes.count == 0

    best_first = NewsItem.find(dupes + [news_item.id]).sort_by { |i| [-(i.absolute_score.to_i), i.published_at] }
    primary = best_first.shift
    best_first.each do |other|
      Rails.logger.info "DUPE: #{primary.title} (#{primary.id}) -> #{other.title} (#{other.id})"
      other.update(dupe_of: primary)
      other.trend_usages.update_all(dupe: true)
      @already_processed << other.id
    end
    @already_processed << primary.id
  end
end
