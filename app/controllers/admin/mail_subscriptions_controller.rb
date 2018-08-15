class Admin::MailSubscriptionsController < AdminController
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
    redirect_to '/admin/sources', notice: 'Mailversand'
  end
end
