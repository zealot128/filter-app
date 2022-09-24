class NewsletterMailer < ApplicationMailer
  def newsletter(mailing, tracking_token)
    @mailing = mailing
    @title = 'Newsletter'

    @tracking_token = tracking_token
    @categories = mailing.categories
    @preview = @mailing.intro
    headers['X-Auto-Response-Suppress'] = "OOF"
    profile_url = edit_mail_subscription_url(@mailing.subscription)
    headers['List-Unsubscribe'] = "<#{profile_url}>"

    mail(to: mailing.full_email, subject: mailing.subject) do |format|
      format.html
    end
  end
end
