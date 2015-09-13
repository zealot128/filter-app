class TwitterSource < Source

  def refresh(take: 50)
    self.class.client.user_timeline(user_name).take(take).each do |tweet|
      TweetProcessor.new.process_tweet(self,tweet)
    end
    self.update_column :error, false
  end

  def to_param
    "#{id}-#{user_name.to_url}"
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

  def remote_url
    "https://twitter.com/#{user_name}"
  end

  def self.client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
      config.access_token        = Rails.application.secrets.twitter_access_token
      config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
    end
  end
end
