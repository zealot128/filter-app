class FacebookSource < Source
  def refresh
    FacebookProcessor.new.run_all(self)
  end

  def download_thumb
    url = agent.page.at('meta[property*=image]')['content']
    agent.get(url)
    Tempfile.open(['download_thumb', agent.page.response['content-type'].split('/').last]) do |tf|
      tf.binmode
      tf.write(agent.page.body)
      tf.flush
      tf.rewind
      update logo: tf
    end
  rescue StandardError => e
    p e
    nil
  end

  def remote_url
    "https://www.facebook.com/#{url}/" #personalwirtschaft.de/?fref=nf
  end

  def agent
    return @m if @m
    @m ||= Mechanize.new
    @m.get(remote_url)
    @m
  end
end
