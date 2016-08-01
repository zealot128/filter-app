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
    news_item.title = link.text

    if news_item.new_record?
      new_m = Mechanize.new
      new_m.get(url)
      news_item.url = new_m.page.uri.to_s
    end
    if news_item.full_text.blank?
      news_item.full_text, = get_full_text_and_image_from_random_link(url)
    end

    text = parent.at('.userContent').text
    filteredText = text.gsub(/[^\p{Word} #\b\.\,\/:]/, '').gsub(/ +/, ' ')
    news_item.teaser = filteredText

    news_item.published_at = Time.at parent.at('.timestampContent').parent['data-utime'].to_i

    if news_item.image.blank?
      if img = parent.at('.fbStoryAttachmentImage img')
        news_item.image = download_url(img['src'])
      end
    end
    news_item.save
  end

end
