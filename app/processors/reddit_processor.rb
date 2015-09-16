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
    if ni.new_record? and data['domain'] != "self.#{@source.name}"
      ni.full_text = get_full_text_from_random_link(url)
    end
    if data['preview'] and ni.image.blank?
      if i=(data['preview']['images']) and image = i.first['source']['url']
        ni.image = download_url(image)
      end
    end
    ni.save
  end

end
