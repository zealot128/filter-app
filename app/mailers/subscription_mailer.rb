class SubscriptionMailer < ActionMailer::Base
  default from: Setting.get('from')
  layout 'newsletter'

  def confirmation_mail(subscription, from: Setting.get('from'))
    @subscription = subscription
    mail to: subscription.full_email, subject: "[#{Setting.site_name}] Bestätigung des E-Mail-Abos",
      from: from
  end

  def reconfirm_mail(subscription, subject:, body:, from: Setting.get('from'))
    @subscription = subscription
    @body = body
    mail to: subscription.full_email, subject: subject, from: from
  end

  def unsubscribe_mail(subscription, subject:, body:, from: Setting.get('from'))
    @subscription = subscription
    @body = body
    mail to: subscription.full_email, subject: subject, from: from
  end
end
