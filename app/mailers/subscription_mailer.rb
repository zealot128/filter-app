class SubscriptionMailer < ActionMailer::Base
  default from: Setting.get('from')
  layout 'newsletter'

  def confirmation_mail(subscription, from: Setting.get('from'))
    @subscription = subscription
    mail to: subscription.full_email, subject: "[#{Setting.site_name}] Bestätigung des E-Mail-Abos",
      from: from
  end
end
