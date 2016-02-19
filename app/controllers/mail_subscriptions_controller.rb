class MailSubscriptionsController < ApplicationController
  def index
    @subscription = MailSubscription.new
    @subscription.interval = 'weekly'
  end

  def create
    @subscription = MailSubscription.new(permitted_params)
    if params[:commit] == 'Vorschau'
      preview(@subscription)
      return
    end
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
    subscription
  end

  def update
    if subscription.update(permitted_params)
      render text: '<div class="alert alert-success">Änderungen gespeichert.</div>', layout: true
    else
      render :edit
    end
  end

  def destroy
    subscription.destroy
    render text: '<div class="alert alert-success">Newsletter abbestellt!</div>', layout: true
  end

  def show
    from = subscription.last_send_date - subscription.interval_from
    preview(subscription, from: from)
  end

  private

  def preview(subscription,from: 1.week.ago.at_end_of_week)
    @mail = NewsletterMailer.newsletter(Newsletter::Mailing.new(subscription, from: from)).body
    render 'preview', layout: false
  end

  def permitted_params
    params.require(:mail_subscription).permit(:interval,
                                              :email,
                                              :first_name,
                                              :last_name,
                                              :gender,
                                              :academic_title,
                                              :position,
                                              :company,
                                              :limit,
                                              categories: [])
  end

  def subscription
    @subscription ||= MailSubscription.find_by_token!(params[:id])
  end
  helper_method :subscription
end
