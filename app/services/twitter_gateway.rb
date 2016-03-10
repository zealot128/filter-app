class TwitterGateway
  attr_reader :api

  def initialize
    @api ||= ::Twitter::REST::Client.new do |config|
      config.consumer_key =      Rails.application.secrets.twitter_consumer_key
      config.consumer_secret =   Rails.application.secrets.twitter_consumer_secret
      config.access_token =        Setting.get('twitter_access_token')
      config.access_token_secret = Setting.get('twitter_access_secret')
    end
  end

  def account
    Setting.get('twitter_account')
  end

  def follow_all(accounts)
    cursor = api.friends
    existing = cursor.to_a.map{|i| i.screen_name}.map(&:downcase)
    to_follow = accounts - existing

    new_follows = []
    to_follow.each do |name|
      if not api.friendship? account, name
        api.follow(name)
        new_follows << name
      end
    end
    new_follows
  end
end
