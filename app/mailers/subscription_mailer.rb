class SubscriptionMailer < ActionMailer::Base
  default from: ::Configuration.from

  def confirmation_mail(subscription)
    @subscription = subscription
    mail to: subscription.email, subject: "[#{::Configuration.site_name}] Bestätigung des E-Mail-Abos"
  end
end
