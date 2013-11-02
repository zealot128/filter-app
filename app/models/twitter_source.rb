class TwitterSource < Source

  def refresh
    self.class.client.user_timeline(user_name).each do |tweet|
      TweetProcessor.new.process_tweet(self,tweet)
    end
  end

  def user_name
    url.gsub('@','')
  end

  def user
    TwitterSource.client.user(url.gsub('@',''))
  end

  def download_thumb
    path = user.profile_image_url.to_s
    self.update_attributes logo: download_url(path)
  end

  def self.client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = "kX94bErw0YBysWtgHsegA"
      config.consumer_secret     = "b9s2IQeUs3OZJladh0QMsNsqqKCdaAdlOSPneVXUbHU"
      config.access_token        = "98188244-PJe2v0Bq4MgPGuqz0j5cJFp9EvoTbTTah2h6MNUpa"
      config.access_token_secret = "TzGlQG44b35OMCQZXI1N8rCWIkjVz6PZBrepaZG8dE"
    end
  end
end
