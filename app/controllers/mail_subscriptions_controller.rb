class MailSubscriptionsController < ApplicationController
  def index
    @subscription = MailSubscription.new
  end

  def create
    @subscription = MailSubscription.new(permitted_params)
    if @subscription.save
      SubscriptionMailer.confirmation_mail(@subscription).deliver_now
      render text: '<div class="alert alert-success">Abonnement erfolgreich. Sie erhalten nun eine Bestätigungsmail, in der Sie den enthaltenen Link anklicken müssen, damit das Abo startet.</div>', layout: true
    else
      render :index
    end
  end

  def confirm
    subscription.confirm!
    render text: '<div class="alert alert-success">Vielen Dank, Ihr Abo ist nun aktiviert.</div>', layout: true
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def permitted_params
    params.require(:mail_subscription).permit(:interval,
                                              :email,
                                              :categories => [])
  end

  def subscription
    @subscription ||= MailSubscription.find_by_token!(params[:id])
  end
  helper_method :subscription
end
