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
        @subscription.save
        SubscriptionMailer.confirmation_mail(@subscription).deliver_now
        render text: '<div class="alert alert-success">Abonnement erfolgreich. Sie erhalten nun eine Bestätigungsmail, ' \
               'in der Sie den enthaltenen Link anklicken müssen, damit das Abo startet.</div>',
               layout: true
      end
    else
      render :index
    end
  end

  def confirm
    subscription.confirm!
    render text: '<div class="alert alert-success">Vielen Dank, Ihr Abo ist nun aktiviert.</div>', layout: true
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
    params.require(:mail_subscription).permit(:interval,
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
      categories: [])
  end
  require "whenever"
  def filter_jobs
    jobs = Whenever::JobList.new(file: Rails.root.join("config", "schedule.rb").to_s).instance_variable_get("@jobs")
    jobs.values.flatten.select do |job|
      job.instance_variable_get("@options")[:task] == "Newsletter::Mailing.cronjob"
    end
  end

  def subscription
    @subscription ||= MailSubscription.find_by!(token: params[:id])
  end
  helper_method :subscription
end
