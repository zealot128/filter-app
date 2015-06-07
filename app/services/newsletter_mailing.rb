class NewsletterMailing
  def initialize(subscription)
    @subscription = subscription
  end

  def can_send?
  end

  def mail
    SubscriptionMailer.newsletter(self)
  end

  private

  def categories

  end

  def news_items
  end

  def interval_from
    {
      'weekly' => 1.week.ago,
      'biweekly' => 2.weeks.ago,
      'monthly' => 1.month.ago
    }[@subscription.interval]
  end

end
