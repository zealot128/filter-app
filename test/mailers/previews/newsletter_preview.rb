class NewsletterPreview < ActionMailer::Preview
  def confirmation_mail
    SubscriptionMailer.confirmation_mail(MailSubscription.last)
  end

  def newsletter
    NewsletterMailer.newsletter(Newsletter::Mailing.new(MailSubscription.last))
  end
end
