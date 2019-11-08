require 'link_extractor'

class TwitterProcessor < BaseProcessor
  def self.process(source)
    new(source).process
  end

  def initialize(source)
    @source = source
  end

  def process(count: @source.created_at > 1.day.ago ? 200 : 20)
    timeline = @source.class.client.user_timeline(@source.user_name, count: count, tweet_mode: "extended")
    timeline.each_with_index do |tweet, i|
      process_tweet(tweet, follow_redirect: i <= 20)
    end
    @source.update_column :error, false
  rescue StandardError => e
    if Rails.env.test?
      raise e
    else
      NOTIFY_EXCEPTION(e)
      @source.update_column :error, true
      @source.update_column :error_message, e.inspect
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def process_tweet(tweet, follow_redirect: true)
    urls = tweet.urls.map { |i| i.expanded_url.to_s }
    urls = urls.map { |url|
      if follow_redirect
        find_unshortened_url(url)
      else
        url
      end
    }
    first_url = urls.find { |url| allowed_url?(url) }

    return if first_url.blank?

    item = news_item_for_tweet(tweet)
    return unless item

    if item.full_text
      if blacklist_filter?(item.title + " " + item.teaser.to_s)
        item.destroy if item.persisted?
        return nil
      else
        item.rescore!
      end
      return
    end

    response = LinkExtractor.run(first_url, close_connection: false)
    if !response || !allowed_url?(response.clean_url)
      item.destroy if item.persisted?
      return nil
    end
    item.url = response.clean_url
    item.full_text = response.full_text
    item.title = response.title || tweet.attrs[:full_text] || tweet.text
    item.teaser = response.teaser.presence || tweet.attrs[:full_text].gsub(%r{https?://[^ ]+}, '')
    item.rescore!

    if response && (img = response.image_blob)
      item.update image: img
    end
  ensure
    response&.shutdown!
  end

  private

  def allowed_url?(url)
    return false if url.blank?
    return false if url['https://twitter.com/']
    if @source.url_rules?
      return @source.url_rules.split.reject(&:blank?).any? { |i| url.downcase.include?(i.downcase) }
    end
    true
  end

  def blacklist_filter?(text)
    NewsItem::CheckFilterList.new(@source).skip_import?(text)
  end

  def news_item_for_tweet(tweet)
    guid = tweet.url.to_s
    item = @source.news_items.where(guid: guid).first_or_initialize
    if blacklist_filter?(tweet.attrs[:full_text])
      item.destroy if item.persisted?
      return nil
    end
    item.published_at = tweet.created_at
    item.retweets = tweet.retweet_count + tweet.favorite_count
    if tweet.retweeted_status.present?
      item.retweets += tweet.retweeted_status.retweet_count
    end
    item.xing ||= 0
    item.fb_likes ||= 0
    item
  end

  def find_unshortened_url(url)
    r = HTTParty.head(url)
    if r.success?
      r.request.last_uri.to_s
    else
      url
    end
  rescue StandardError => e
    NOTIFY_EXCEPTION(e)
    url
  end
end
