class FacebookSource < Source

  def refresh
    FacebookProcessor.new.run_all(self)
  end

  def download_thumb
    path = agent.page.at('img.profilePic')['src'] rescue nil
    update_attributes logo: download_url(path)
  end

  def remote_url
    "https://www.facebook.com/#{name}/" #personalwirtschaft.de/?fref=nf
  end

  def agent
    return @m if @m
    @m ||= Mechanize.new
    @m.get(remote_url)
    @m
  end
end
