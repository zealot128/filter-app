class MediaUrls
  def run
    sources = [PodcastSource, YoutubeSource]
    sources.each do |s|
      s.all.each do |ss|
        ss.refresh
      end
    end
  end
end