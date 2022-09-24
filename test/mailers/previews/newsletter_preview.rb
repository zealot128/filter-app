class NewsletterPreview < ActionMailer::Preview
  def confirmation_mail
    SubscriptionMailer.confirmation_mail(mail_subscription)
  end

  def newsletter
    NewsletterMailer.newsletter(Newsletter::Mailing.new(mail_subscription), '123123')
  end

  def reconfirm
    inactivity = Newsletter::Inactivity.new(mail_subscription)
    next_mail = Newsletter::Inactivity.reminders[1]

    SubscriptionMailer.reconfirm_mail(mail_subscription, subject: next_mail[:subject], body: next_mail[:body])
  end

  def unsubscribe_mail
    inactivity = Newsletter::Inactivity.new(mail_subscription)
    subject = Setting.get('reminder_unsubscribe_notice_subject')
    body = Setting.get('reminder_unsubscribe_notice_body')

    SubscriptionMailer.unsubscribe_mail(mail_subscription, subject: subject, body: body)
  end

  private

  def mail_subscription
    MailSubscription.confirmed.order('RANDOM()').first!
  end
end
