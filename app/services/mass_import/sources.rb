module MassImport
  class Sources
    attr_reader :m, :url, :feed_url

    ## USAGE:
    # MassImport::Sources.new("https://bitcoinblog.de").run
    # MassImport::Sources.new("https://bitcoinblog.de/").run(language: 'de', full_text_selector: '.entry', source_type: 'PodcastSource')
    #

    def initialize(url)
      @url = url
      m = Mechanize.new
      m.verify_mode = OpenSSL::SSL::VERIFY_NONE
      m.read_timeout=10
      m.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:44.0) Gecko/20100101 Firefox/44.0'
      m.request_headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
      @m=m
    end

    def skip?(test_url: url)
      host = URI.parse(test_url).host
      Source.where('url like ?', "%#{host}%").count > 0
    end

    def run(full_text_selector: nil, source_type: 'FeedSource', language: 'de')
      puts "-> #{url}"
      return if skip?
      begin
        m.get(url)
      rescue SocketError, Mechanize::ResponseCodeError => e
        puts "  FEHLER #{url} -> #{e.inspect}"
        return
      end
      title = m.page.title.to_s.split('|').first

      @feed_url = find_feed_url()
      if !@feed_url
        puts "  FEHLER #{url} - keine Feed URL gefunden"
        return
      end
      return if @feed_url && skip?(test_url: @feed_url)
      if !@feed_url[/^http/]
        @feed_url = URI.join(url, @feed_url).to_s
      end
      selector = full_text_selector || find_selector_by_feed_url
      if !selector
        puts "  FEHLER KEIN selector found #{@feed_url}"
      end

      source = source_type.constantize.new(url: @feed_url, name: title, full_text_selector: selector)
      source.language = language
      source.value = 1
      if source.save
        puts "  CREATING #{@feed_url} \"#{title}\" with selector \"#{selector}\"..."
      else
        puts "  FEHLER #{url} Erstellung fehlgeschlagen #{source.errors.as_json.to_s}"
      end
    end

    def find_feed_url
      feed_url_by_body = m.page.search('link[rel=alternate]').
        select{|i| i['type'].to_s[/rss|atom|xml/] }.
        reject{|i| i['href']['comments']}.map{|i| i['href']}.first

      return feed_url_by_body if feed_url_by_body

      try_urls = [
        url + "/feed",
        url + "/index.php/feed",
        url + "/blog/feed",
        url + "/rss",
        url + "/feed/atom",
        url + "/news/feed",
        url + "/wordpress/feed",
        url + "/feeds/posts/default",
        url + "/de/feed/",
        url + "/blog?format=RSS"
      ]
      try_urls.each do |try_url|
        begin
          m.get(try_url)
          puts "   trying #{try_url}"
          if m.page.response['content-type'].to_s[/rss|atom|xml/]
            return try_url
          end
        rescue Mechanize::ResponseCodeError, Mechanize::RedirectLimitReachedError, SocketError
        end
      end
      nil
    end

    def find_selector_by_feed_url
      begin
        m.get @feed_url
      rescue Mechanize::ResponseCodeError
        return
      end
      if m.page.code == "301" and (loc=m.page.response['location']) and loc != @feed_url
        puts "  Feed URL weiterleitung nach #{loc}"
        @feed_url = loc
        m.get loc
      end
      doc = Nokogiri::XML.parse(m.page.body)
      path = [ 'item link', 'item guid', 'entry link[rel=alternate]', 'entry link'].find {|tpath|
        doc.at(tpath)
      }
      return nil if !path
      node = doc.at(path)
      link = (node.inner_html.presence || node['href']).to_s.strip
      m.get(link)
      if defined?(m.page.at)
        BaseProcessor::RULES.find do |rule|
          if m.page.at(rule)
            return rule
          end
        end
      end
      nil
    end
  end
end
