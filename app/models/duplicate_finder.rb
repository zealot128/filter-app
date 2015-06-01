class DuplicateFinder
  def self.run
    NewsItem.group(:source_id, :title).having('count(*) > 1').pluck(:source_id, :title, 'count(*)').map do |source_id, title, count|
      Source.find(source_id).news_items.where(title: title).order('created_at asc').limit(count - 1).each(&:destroy)
    end
  end
end
