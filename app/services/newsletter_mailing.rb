class NewsletterMailing
  attr_reader :subscription
  def initialize(subscription)
    @subscription = subscription
  end

  def mail
    SubscriptionMailer.newsletter(self)
  end

  def email
    @subscription.email
  end

  def categories
    Category.find(@subscription.categories.reject(&:blank?))
  end

  def top_news_items_for(category)
    all = NewsItem.
      joins(:categories).
      where(categories: { id: category}).
      group('news_items.id').
      where('published_at > ?', interval_from).
      order('absolute_score desc')

    count = all.count
    limit = case count
            when 0..5 then count
            when 5..50 then 5 + (count - 5) / 2
            when 50..10000 then (count ** 0.8).to_i
            end
    all.limit(limit)
  end

  def interval_from
    {
      'weekly' => 1.week.ago,
      'biweekly' => 2.weeks.ago,
      'monthly' => 1.month.ago
    }[@subscription.interval]
  end

end
