class NewsletterWorker
  include Sidekiq::Worker

  def perform(mail_subscription_id)
    mail_subscription = MailSubscription.confirmed.find(mail_subscription_id)
    ms = Newsletter::Mailing.new(mail_subscription)
    ms.send! if ms.sendable?
  end
end
