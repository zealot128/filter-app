class FacebookProcessor < BaseProcessor
  def run_all(source)
    get source.remote_url
    @m.page.search('._52c6').each do |item|
        process_dom_item(item.ancestors('[data-gt]').first, source)
    rescue Mechanize::ResponseCodeError
    end
  ensure
    @m.shutdown
    @m = nil
  end

  def process_dom_item(parent, source)
    link = parent.at('[rel=nofollow]')

    url = link['onmouseover'].split('"')[1].gsub("\\/", "/")

    news_item = source.news_items.where(guid: url).first_or_initialize
    news_item.title = parent.at('._5s6c a').text

    if news_item.new_record?
      new_m = Mechanize.new
      new_m.get(url)
      news_item.url = new_m.page.uri.to_s
      new_m.shutdown
    end

    text = parent.at('.userContent').text
    filtered_text = text.gsub(%r{[^\p{Word} #\b\.\,/:]}, '').squeeze(' ')
    news_item.teaser = filtered_text
    news_item.published_at = Time.zone.at parent.at('.timestampContent').parent['data-utime'].to_i
    news_item.rescore!
    NewsItem::FullTextFetcher.new(news_item, unknown_selector: true).run if news_item.full_text.blank?
  end
end
