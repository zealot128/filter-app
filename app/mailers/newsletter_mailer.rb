class NewsletterMailer < ActionMailer::Base
  default from: ::Configuration.from
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
    mail to: mailing.email, subject: "[#{::Configuration.site_name}] #{@mailing.count} Beiträge #{names}"
  end
end
