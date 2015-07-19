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
    all = categories.map { |category|
      [ category, *top_news_items_for(category)]
    }
    filter_doubles(all).reject{|c,ni| ni.count == 0 }
  end


  def categories
    Category.find(@subscription.categories.reject(&:blank?))
  end

  private

  def filter_doubles(categories_with_counts)
    filtered = []
    categories_with_counts.map do |cat, nis, total_count|
      ids = nis.pluck(:id)
      if filtered.present?
        filtered_nis = nis.where("news_items.id not in (?)", filtered)
      else
        filtered_nis = nis
      end
      filtered += ids
      [ cat, filtered_nis, total_count]
    end
  end

  def top_news_items_for(category)
    all = NewsItem.
      joins(:categories).
      where(categories: { id: category}).
      group('news_items.id').
      where('published_at > ?', subscription.interval_from.ago).
      order('absolute_score desc')

    count = all.length
    limit = limit_fn(count)
    [all.limit(limit), count]
  end

  def limit_fn(count)
    case count
    when 0..5 then count
    when 5..10000 then 5 + ((count - 5) ** 0.55).to_i
    end
  end

end
