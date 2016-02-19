class SubscriptionMailer < ActionMailer::Base
  default from: Setting.get('from')

  def confirmation_mail(subscription)
    @subscription = subscription
    mail to: subscription.email, subject: "[#{Setting.site_name}] Bestätigung des E-Mail-Abos"
  end
end
