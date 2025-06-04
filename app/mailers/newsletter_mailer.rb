class NewsletterMailer < ApplicationMailer
  def newsletter(mailing, tracking_token)
    @mailing = mailing
    @title = 'Newsletter'

    @tracking_token = tracking_token
    @categories = mailing.categories
    # mrjml does not support html in mjml-preview yet
    @preview = @mailing.intro.remove(/<[^\]]+>/)
    headers['X-Auto-Response-Suppress'] = "OOF"
    profile_url = edit_mail_subscription_url(@mailing.subscription)
    headers['List-Unsubscribe'] = "<#{profile_url}>"

    show_ad = AdLogic.enabled? && AdLogic.promoted_events.any?
    if show_ad
      all_events = AdLogic.promoted_events
      @events = all_events.select { |event| event.from > Time.zone.now }
    end

    mail(to: mailing.full_email, subject: mailing.subject) do |format|
      format.html
    end
  end
end
