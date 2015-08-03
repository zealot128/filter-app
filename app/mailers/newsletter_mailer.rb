class NewsletterMailer < ActionMailer::Base
  default from: 'noreply@hrfilter.de'
  include Roadie::Rails::Mailer
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
    roadie_mail to: mailing.email, subject: "[HRfilter] #{@mailing.news_items.count} Beiträge #{names}"
  end
end
