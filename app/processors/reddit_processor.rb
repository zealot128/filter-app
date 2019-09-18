require 'fetcher'
require 'download_url'
require 'link_extractor'

class RedditProcessor < BaseProcessor
  class InvalidItemDelete < StandardError
  end

  def self.process(source)
    new(source).process
  end

  def initialize(source)
    @source = source
  end

  def process
    url = @source.url + '/.json'
    json = JSON.load Fetcher.fetch_url(url).body
    json['data']['children'].each do |child|
      process_item(child['data'])
    end
  end

  def process_item(data)
    url = data['url']
    id = data['id']
    ni = @source.news_items.where(guid: id).first_or_initialize
    if data['over_18'] || data['hidden'] || data['thumbnail'] == 'nsfw'
      raise InvalidItemDelete
    end

    # Check if item with same url already exists
    if url.present? and @source.news_items.where(url: url).where('guid != ?', id).any?
      raise InvalidItemDelete
    end

    ni.title = data['title'].truncate(255)
    ni.url = url
    ni.reddit = data['score']
    ni.published_at = Time.zone.at data['created_utc']
    ni.xing ||= 0
    ni.linkedin ||= 0
    ni.fb_likes ||= 0
    ni.retweets ||= 0
    ni.teaser = data['selftext']
    response = nil
    if ni.full_text.blank? and data['domain'] != "self.#{@source.name}"
      response = LinkExtractor.run(url, close_connection: false)
      if !response
        raise InvalidItemDelete
      end
      ni.url = response.clean_url
      ni.full_text = response.full_text
    end
    if ni.teaser.blank? and ni.full_text.present?
      ni.teaser = teaser(ni.full_text)
    end
    if NewsItem::CheckFilterList.new(@source).skip_import?(ni.title, ni.teaser)
      raise InvalidItemDelete
    end
    if data['preview'] and ni.image.blank?
      if (i = data['preview']['images']) and (image = i.first['source']['url'])
        ni.image = download_url(image)
      end
    end
    ni.save

    if response && ni.image.blank? && (img = response.image_blob)
      ni.update image: img
    end
  rescue InvalidItemDelete
    ni.destroy if ni.persisted?
    nil
  end
end
