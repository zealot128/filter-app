class NewsletterMailer < ActionMailer::Base
  default from: 'noreply@hrfilter.de'
  include Roadie::Rails::Mailer
  def newsletter(mailing)
    @mailing = mailing
    @title = 'Newsletter'

    roadie_mail to: mailing.email, subject: '[HRfilter] Newsletter'
  end
end
