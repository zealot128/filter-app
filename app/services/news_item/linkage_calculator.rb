class NewsItem::LinkageCalculator
  def self.run(scope: NewsItem.current)
    scope.find_each do |s|
      next unless s.full_text.present?
      new(s).run
    end
  end

  def initialize(news_item)
    @news_item = news_item
  end

  def run
    links.each do |link|
      if ref = NewsItem.where('url like ?', "%#{link}%").first
        if ref.incoming_links.where(from_id: @news_item.id).none?
          ref.incoming_links << Linkage.new(from_id: @news_item.id, different: @news_item.source_id != ref.source_id)
          ref.save
        end
      end
    end
  end

  def links
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
    begin
      URI.join(@news_item.url, l).to_s
    rescue URI::InvalidURIError
      nil
    end
  end
end
