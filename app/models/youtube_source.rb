class YoutubeSource < Source
  validates :url, presence: true, format: { with: %r{\Ahttps://www.youtube.com/user/[^ ]+\z} }

  def download_thumb
    doc = Nokogiri.parse(open(url))
    img = doc.at('img.channel-header-profile-image')
    return if img.blank? or img['src'].blank?
    update_attributes logo: download_url(img['src'])
  end

  def refresh
    YoutubeProcessor.new.process(self)
    true
  end
end
