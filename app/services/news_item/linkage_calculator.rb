class NewsItem::LinkageCalculator
  def self.run(scope: NewsItem.current)
    scope.find_each do |s|
      next if s.full_text.blank?

      new(s).run
    end
  end

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    links.each do |link|
      if (ref = NewsItem.find_by('url like ?', "%#{link}%"))
        if ref.incoming_links.where(from_id: @news_item.id).none?
          ref.incoming_links << Linkage.new(from_id: @news_item.id, different: @news_item.source_id != ref.source_id)
          ref.save
        end
      end
    end
  end

  def links
    return [] if @news_item.full_text.blank?

    doc = Nokogiri::HTML.fragment("<div>" + @news_item.full_text + "</div>")
    doc.search('a').map do |link|
      l = link['href']
      if l
        unless l[%r{^http|//}]
          l = make_url_absolute(l)
          next unless l
        end
        l.gsub!(/\?utm_source.*/, "")
        l.gsub!(/https?:\/\/(www\.)?/, '')
      end
      l
    end.compact.uniq
  end

  def make_url_absolute(l)
    URI.join(@news_item.url, l).to_s
  rescue URI::InvalidURIError, URI::InvalidComponentError
    nil
  end
end
