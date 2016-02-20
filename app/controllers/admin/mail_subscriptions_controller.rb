class Admin::MailSubscriptionsController < AdminController
  def index
    @subscriptions = MailSubscription.all
  end

  def confirm
    @subscription = MailSubscription.find_by!(token: params[:id])
    SubscriptionMailer.confirmation_mail(@subscription).deliver_now
    redirect_to '/admin/sources', notice: 'Mailversand'
  end
end
