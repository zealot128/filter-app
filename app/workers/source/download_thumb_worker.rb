class Source::DownloadThumbWorker
  include Sidekiq::Worker

  def perform(source_id)
    source = Source.find(source_id)
    source.download_thumb
  end
end
