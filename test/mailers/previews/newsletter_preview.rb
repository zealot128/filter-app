class NewsletterPreview < ActionMailer::Preview
  def confirmation_mail
    SubscriptionMailer.confirmation_mail(MailSubscription.last)
  end

  def newsletter
    subscription = MailSubscription.joins(:histories).group('mail_subscriptions.id').first
    history = subscription.histories.last
    NewsletterMailer.newsletter(Newsletter::Mailing.new(subscription), history)
  end

  def initial_mail
    NewsletterMailer.initial_mail(MailSubscription.last)
  end
end
