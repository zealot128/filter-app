class TweetProcessor < Processor
  def process_tweet(source, tweet)
    url = tweet.url.to_s
    guid = url

    item = source.news_items.where(guid: guid).first_or_initialize
    item.title = tweet.text
    item.published_at = tweet.created_at
    item.url = url
    item.retweets = tweet.retweet_count + tweet.favorite_count
    if tweet.retweeted_status.present?
      item.retweets += tweet.retweeted_status.retweet_count
    end

    if (link = tweet.urls.first.try(:expanded_url)) and item.full_text.blank?
      item.full_text, = get_full_text_and_image_from_random_link(link)
    else
      item.destroy unless item.new_record?
      # Tweets ohne Link sind doof
      return
    end
    if NewsItem::CheckFilterList.new(source).skip_import?(tweet.text)
      item.destroy if item.persisted?
      return nil
    end
    item.xing ||= 0
    item.linkedin ||= 0
    item.fb_likes ||= 0
    item.gplus ||= 0

    item.rescore!
  end
end
