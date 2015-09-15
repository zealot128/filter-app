class Admin::MailSubscriptionsController < AdminController
  def index
    @subscriptions = MailSubscription.all
  end
end
