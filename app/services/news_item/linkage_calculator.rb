class NewsItem::LinkageCalculator
  def self.run(scope: NewsItem.current)
    scope.find_each do |s|
      next if !s.full_text.present?
      doc = Nokogiri::HTML.fragment("<div>" + s.full_text + "</div>")
      doc.search('a').each do |link|
        l = link['href']
        next if l.blank?
        l.gsub!(/\?utm_source.*/,"")
        l.gsub!(/https?:\/\/(www\.)?/, '')
        if ref = NewsItem.where('url like ?', "%#{l}%").first
          if !ref.referenced_news.to_a.include?(ref)
            ref.referenced_news << ref
            ref.save
          end
        end
      end
    end
  end
end
