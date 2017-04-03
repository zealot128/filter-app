class FacebookProcessor < Processor
  def run_all(source)
    get source.remote_url
    @m.page.search('._52c6').each do |item|
      begin
        process_dom_item(item.ancestors('[data-gt]').first, source)
      rescue Mechanize::ResponseCodeError
      end
    end
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
    end

    text = parent.at('.userContent').text
    filteredText = text.gsub(/[^\p{Word} #\b\.\,\/:]/, '').gsub(/ +/, ' ')
    news_item.teaser = filteredText
    news_item.published_at = Time.at parent.at('.timestampContent').parent['data-utime'].to_i
    news_item.rescore!
    if !news_item.full_text.present?
      NewsItem::FullTextFetcher.new(news_item, unknown_selector: true).run
    end
  end
end
