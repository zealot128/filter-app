class NewsletterMailer < ActionMailer::Base
  layout 'newsletter'
  default from: Setting.get('from')
  def newsletter(mailing)
    @mailing = mailing
    @title = 'Newsletter'

    @categories = mailing.categories
    names = @categories.map(&:name)
    if names.count > 5
      names = "aus #{names.count} Themen"
    else
      names = "zum Thema " + names.to_sentence
    end
    mail to: mailing.email, subject: "[#{Setting.site_name}] #{@mailing.count} Beiträge #{names}"
  end

  def initial_mail(subscription)
    @subscription = subscription
    mail to: subscription.email, subject: "Empfehlungsbund-Newsletter jetzt HRfilter.de"
  end
end
