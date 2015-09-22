require 'fetcher'
require 'download_url'
class RedditProcessor < Processor
  def process(source)
    @source = source
    url = source.url + '/.json'
    json = JSON.load Fetcher.fetch_url(url).body
    json['data']['children'].each do |child|
      process_child(child['data'])
    end
  end

  def process_child(data)
    url = data['url']
    id = data['id']

    ni = @source.news_items.where(guid: id).first_or_initialize
    ni.title = data['title']
    ni.url = url
    ni.reddit = data['score']
    ni.published_at = Time.at data['created_utc']
    ni.xing ||= 0
    ni.linkedin ||= 0
    ni.fb_likes ||= 0
    ni.retweets ||= 0
    ni.gplus ||= 0
    ni.teaser = data['selftext']
    mechanize = nil
    if ni.full_text.blank? and data['domain'] != "self.#{@source.name}"
      ni.full_text, mechanize = get_full_text_and_image_from_random_link(url)
    end
    if ni.teaser.blank? and ni.full_text.present?
      ni.teaser = teaser(ni.full_text)
    end
    if data['preview'] and ni.image.blank?
      if i = (data['preview']['images']) and image = i.first['source']['url']
        ni.image = download_url(image)
      end
    end
    ni.save
    if mechanize
      NewsItem::ImageFetcher.new(ni, mechanize.page).run
    end
  end
end
