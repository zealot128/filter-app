class Source::DownloadThumbJob < ApplicationJob
  def perform(source_id)
    source = Source.find(source_id)
    source.download_thumb
  end
end
