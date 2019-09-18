class Source::FetchWorker
  include Sidekiq::Worker

  def perform(source_id)
    puts "1"
    source = Source.find(source_id)
    puts "2"
    source.wrapped_refresh!
    puts "3"
    source.news_items.current.each(&:rescore!)
    puts "4"
  end
end
