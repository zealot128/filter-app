class NewsletterMailing
  attr_reader :subscription

  def self.cronjob
    MailSubscription.confirmed.each do |s|
      ms = new(s)
      if ms.sendable?
        ms.send!
      end
    end
  end

  def initialize(subscription)
    @subscription = subscription
  end

  def sendable?
    categories_with_news.count > 0 && subscription.due?
  end

  def send!
    begin
      mail.deliver_now!
    rescue StandardError => e
      puts "[NewsletterMailing] #{e.inspect}"
    ensure
      subscription.update_column :last_send_date, Date.today
    end
  end

  def mail
    NewsletterMailer.newsletter(self)
  end

  def email
    @subscription.email
  end

  def categories_with_news
    categories.map do |category|
      [ category, *top_news_items_for(category)]
    end.reject{|c,ni| ni.count == 0 }
  end


  def categories
    Category.find(@subscription.categories.reject(&:blank?))
  end

  private

  def top_news_items_for(category)
    all = NewsItem.
      joins(:categories).
      where(categories: { id: category}).
      group('news_items.id').
      where('published_at > ?', subscription.interval_from.ago).
      order('absolute_score desc')

    count = all.length
    limit = limit_fn(count)
    [all.limit(limit).to_a, count]
  end

  def limit_fn(count)
    case count
    when 0..5 then count
    when 5..10000 then 5 + ((count - 5) ** 0.55).to_i
    end
  end

end
