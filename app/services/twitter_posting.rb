class TwitterPosting
  def self.cronjob(from: 2.days.ago, to: Time.zone.now)
    return if !Setting.get('twitter_access_token')
    candidates = AdLogic.twitter_news(from, to)

    candidates.select { |i| i.tweet_id.blank? }.take(1).each do |ni|
      new(ni).run
    end
  end

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    Rails.logger.info "[TwitterPosting]: #{tweet}"
    response = TwitterGateway.new.api.update(tweet)
    @news_item.update(tweet_id: response.id.to_s)
  rescue Twitter::Error::Forbidden => e
    if e.to_s['You currently have access to a subset']
      # nothing to do here.
      return
    end
    raise e
  end

  def tweet
    @tweet ||=
      begin
        url = "https://www.#{Rails.configuration.secrets.domain_name}/ni/#{@news_item.id}?utm_source=twitter&utm_medium=main"
        meta_data = "#{maybe_mention}#{maybe_hashtags}"
        length = 280 - 24 - 1 - meta_data.length
        title = @news_item.title.strip.truncate(length)
        "#{title} #{url}#{meta_data}"
      end
  end

  def maybe_hashtags
    c = @news_item.categories.take(1).map { |i| "##{i.hash_tag}" }.join(' ')
    if c.present?
      c.prepend(" ")
    else
      c
    end
  end

  def maybe_mention
    @news_item.source.twitter_account.present? ? " @#{@news_item.source.twitter_account}" : ""
  end
end
