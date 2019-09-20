xml.instruct!
xml.rss(version: "2.0",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title Setting.site_name
    xml.lastBuildDate Time.zone.now
    xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: request.path)
    @news_items.each do |ni|
      xml.item do
        xml.title ni.title + " (#{ni.source.name})"
        xml.link click_proxy_url(ni)
        xml.pubDate ni.published_at.rfc822
        xml.guid ni.guid
        if ni.image.present?
          xml.tag!("media:content", "xmlns:media" => "http://search.yahoo.com/mrss/", url: root_url + ni.image.url, medium: "image", type: "image/jpeg")
        end
        xml.description do
          xml.cdata!(description(ni))
        end
      end
    end
  end
end
