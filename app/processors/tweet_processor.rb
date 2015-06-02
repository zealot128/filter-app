class TweetProcessor < Processor
  def process_tweet(source, tweet)
    rules = %w[
      #main-content
      #main\ .content
      #articleContent
      .node-content
      .transcript
      #articleContent
      #content
      .post-content
      .postContent
      .hcf-content
      .entry-content
      .entryContent
      .content
      article
    ]

    url = tweet.url.to_s
    guid = url

    item = source.news_items.where(guid: guid).first_or_initialize
    item.title = tweet.text
    item.published_at = tweet.created_at
    item.url = url
    item.retweets = tweet.retweet_count + tweet.favourite_count
    if tweet.retweeted_status.present?
      item.retweets += tweet.retweeted_status.retweet_count
    end

    if (link = tweet.urls.first.try(:expanded_url)) and item.full_text.blank?
      begin
        res = get(link.to_s)
        if html = res.at(rules.join(', '))
          item.full_text = clear html.to_s
        end
      rescue StandardError, Net::HTTPServiceUnavailable
        item.full_text = ""
      end
    end
    item.xing = 0
    item.linkedin = 0
    item.fb_likes = 0
    item.gplus = 0

    item.value = item.score
    item.save
  end
end
