# :nocov:
# rubocop:disable Rails/Output,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Style/GuardClause
module MassImport
  class AutoAssignTwitter < Processor
    def self.run_all
      FeedSource.where(twitter_account: nil).find_each do |a|
        AutoAssignTwitter.new(a).run
      end
    end

    def initialize(source)
      @source = source
    end

    def run(news_item: @source.news_items.order('created_at desc').first, count: 0)
      return if @source.twitter_account
      return if count > 3
      return unless news_item
      if count == 0
        base_url = URI.parse(news_item.url).tap { |q| q.path = '/' }.to_s
        page = get base_url
        find_link_on_page(page)
      end
      return if @source.twitter_account

      page = get news_item.url
      find_link_on_page(page)
      return if @source.twitter_account
      puts "Nichts gefunden #{@source.name}"
    rescue Mechanize::ResponseCodeError, SocketError, SystemCallError, URI::InvalidURIError => e
      puts "FEHLER bei #{@source.name} -> #{e.inspect}"
      run(news_item: @source.news_items.order('created_at desc')[count + 1], count: count + 1)
    end

    def find_link_on_page(page)
      if (intent = page.links.select { |i| i.href.to_s['https://twitter.com/intent/follow'] }.first)
        assign_account CGI.parse(URI.parse(intent.href).query)['screen_name'].first
      end
      if (intent = page.links.select { |i| i.href.to_s[%r{twitter.com/(#\!/)?\w+/?$}] && !i.href[/share/] }.first)
          acc = intent.href.split('/').last
        assign_account acc
      end
    end

    private

    def assign_account(a)
      return unless a
      @source.twitter_account = a
      puts "Found Twitter-Account #{a} #{@source.name}" if @source.save
    end
  end
end
# :nocov:
