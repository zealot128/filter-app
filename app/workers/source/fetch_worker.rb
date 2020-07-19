class Source::FetchWorker
  include Sidekiq::Worker

  def perform(source_id)
    source = Source.find(source_id)
    source.wrapped_refresh!
    source.news_items.current.each(&:rescore!)
  end
end
