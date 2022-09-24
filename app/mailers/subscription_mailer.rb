class SubscriptionMailer < ApplicationMailer
  def confirmation_mail(subscription, from: Setting.get('from'))
    @subscription = subscription
    mail to: subscription.full_email,
         subject: "[#{Setting.site_name}] Bestätigung des E-Mail-Abos",
         from: from
  end

  def reconfirm_mail(subscription, subject:, body:, from: alternate_from)
    @subscription = subscription
    @body = body
    mail to: subscription.full_email, subject: subject, from: alternate_from, bcc: bccs
  end

  def unsubscribe_mail(subscription, subject:, body:, from: alternate_from)
    @subscription = subscription
    @body = body
    mail to: subscription.full_email, subject: subject, from: from, bcc: bccs
  end

  private

  def bccs
    User.admin.pluck(:email)
  end

  def alternate_from
    Setting.get('person_email').presence || Setting.get('email').presence || Setting.get('from')
  end
end
