class Source::RescoreAllJob < ApplicationJob
  def perform(source_id)
    source = Source.find(source_id)
    source.news_items.where('published_at > ?', 2.years.ago).find_each(&:rescore!)
  end
end
