class ApplicationMailer < ActionMailer::Base
  default from: Setting.get('from')
  layout 'newsletter_mjml'
end
