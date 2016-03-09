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
    return if !news_item
    s = get news_item.url
    if intent = s.links.select{|i| i.href.to_s['https://twitter.com/intent/follow']}.first
      assign_account  CGI.parse(URI.parse(intent.href).query)['screen_name'].first
      return
    end
    if intent = s.links.select{|i| i.href.to_s[%r{twitter.com/\w+/?$}]}.first
      acc = intent.href.to_s[%r{twitter.com/(\w+)/?$}, 1]
      return if !acc[/share/]
      assign_account acc
      return
    end
    puts "Nichts gefunden #{@source.name}"
  rescue Mechanize::ResponseCodeError, SocketError => e
    puts "FEHLER bei #{@source.name} -> #{e.inspect}"
    run(news_item: @source.news_items.order('created_at desc')[count + 1], count: count + 1)
  end

  private

  def assign_account(a)
    if a
      @source.twitter_account = a
      if @source.save
        puts "Found Twitter-Account #{a} #{@source.name}"
      end
    end
  end
end

