# rubocop:disable Rails/OutputSafety
class MailSubscriptionsController < ApplicationController
  def index
    @subscription = MailSubscription.new
    @subscription.interval = 'weekly'
  end

  def embed
    @subscription = MailSubscription.new
    @subscription.interval = 'weekly'
    response.headers.delete('X-Frame-Options')
    render layout: 'embed'
  end

  def create
    @subscription = MailSubscription.new(permitted_params)
    if @subscription.valid?
      if params[:commit] == 'Vorschau'
        from = Time.zone.now - subscription.interval_from
        preview(@subscription, from: from)
        return
      else
        ahoy.track 'newsletter_subscribe'
        @subscription.save
        SubscriptionMailer.confirmation_mail(@subscription).deliver_now
        render html: '<div class="alert alert-success">Abonnement erfolgreich. Sie erhalten nun eine Bestätigungsmail, ' \
                  'in der Sie den enthaltenen Link anklicken müssen, damit das Abo startet. <br>Sollten Sie keine ' \
                  'E-Mail-Bestätigung erhalten haben, überprüfen Sie ggf. Ihren Spam-Ordner. </div>'.html_safe,
               layout: true
      end
    else
      render :index
    end
  end

  def reconfirm
    subscription.update(number_of_reminder_sent: 0, last_reminder_sent_at: nil, created_at: Time.zone.now)
    redirect_to edit_mail_subscription_path, notice: "Vielen Dank! Ihr Abonnement wurde erneut bestätigt."
  end

  def confirm
    ahoy.track 'newsletter_confirm'
    subscription.confirm!
    render html: '<div class="alert alert-success">Vielen Dank, Ihr Abo ist nun aktiviert.</div>'.html_safe, layout: true
    time_now = Time.zone.now
    job = filter_jobs
    cronjob_time = Time.zone.parse(job[0].at).strftime('%H:%M')
    return if time_now.monday? and cronjob_time > time_now.strftime('%H:%M')

    mailing = Newsletter::Mailing.new(subscription, from: 1.week.ago.at_beginning_of_week)
    mailing.send!
    subscription.update(last_send_date: nil)
  end

  def edit
    subscription
  end

  def update
    if subscription.update(permitted_params)
      ahoy.track 'newsletter_update'
      render html: '<div class="alert alert-success">Änderungen gespeichert.</div>'.html_safe, layout: true
    else
      render :edit
    end
  end

  def destroy
    ahoy.track 'newsletter_unsubscribe'
    subscription.destroy
    render html: '<div class="alert alert-success">Newsletter abbestellt!</div>'.html_safe, layout: true
  end

  def show
    from = if subscription.last_send_date
             subscription.last_send_date - subscription.interval_from
           else
             Time.zone.now - subscription.interval_from
           end
    preview(subscription, from: from)
  end

  def track_open
    ignore = (request.ip == '217.92.174.98') || IPCat.datacenter?(request.ip)
    unless ignore
      ahoy.track 'newsletter_open'
      history = MailSubscription::History.find_by(open_token: params[:token])
      history.update(opened_at: Time.zone.now) if history && history.opened_at.nil?
    end
    respond_to do |format|
      format.png {
        send_file File.open("app/assets/images/#{Setting.key}/logo-large.png"), disposition: 'inline', type: 'image/png'
      }
      format.gif {
        send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline")
      }
    end
  end

  private

  def preview(subscription, from: 1.week.ago.at_beginning_of_week)
    open_token = subscription.histories.order('created_at desc').first.try(:open_token)
    @mail = NewsletterMailer.newsletter(Newsletter::Mailing.new(subscription, from: from), open_token)
    ActionMailer::Base.preview_interceptors.each { |i| i.previewing_email(@mail) }
    @body = @mail.html_part.body.to_s
    render 'preview', layout: false
  end

  def permitted_params
    params.require(:mail_subscription).permit(
      :interval,
      :email,
      :first_name,
      :last_name,
      :gender,
      :academic_title,
      :position,
      :company,
      :extended_member,
      :limit,
      :privacy,
      categories: []
    )
  end

  require "whenever"
  def filter_jobs
    jobs = Whenever::JobList.new(file: Rails.root.join("config", "schedule.rb").to_s).instance_variable_get("@jobs")
    jobs[:default_mailto].values.flatten.select { |job| job.instance_variable_get("@options")[:task]&.include?("Newsletter::Mailing.cronjob") }
  end

  def subscription
    @subscription ||= MailSubscription.find_by!(token: params[:id])
  end
  helper_method :subscription
end
