class Admin::MailSubscriptionsController < AdminController
  authorize_resource
  def index
    @subscriptions = MailSubscription.order('created_at desc')
    respond_to do |f|
      f.html
      f.json {
        render json: @subscriptions.as_json
      }
    end
  end

  def confirm
    @subscription = MailSubscription.find_by!(token: params[:id])
    SubscriptionMailer.confirmation_mail(@subscription).deliver_now
    redirect_to '/admin/mail_subscriptions', notice: 'Bestätigungsmail erneut versendet.'
  end

  def destroy
    @subscription = MailSubscription.find_by!(token: params[:id])
    @subscription.destroy
    redirect_to '/admin/mail_subscriptions', notice: 'Gelöscht.'
  end
end
