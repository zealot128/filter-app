class MailSubscriptionsController < ApplicationController
  def index
    @subscription = MailSubscription.new
  end

  def create
    @subscription = MailSubscription.new(permitted_params)
    if @subscription.save
      SubscriptionMailer.confirmation_mail(@subscription).deliver_now
      render text: 'Abonnement erfolgreich. Sie erhalten nun eine Bestätigungsmail, in der Sie den enthaltenen Link anklicken müssen, damit das Abo startet.', layout: true
    else
      render :index
    end
  end

  def confirm
    subscription.confirm!
    render text: 'Vielen Dank, Ihr Abo ist nun aktiviert.', layout: true
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
