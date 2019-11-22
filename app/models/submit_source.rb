class SubmitSource < MailForm::Base
  attribute :url, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :comment

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "[#{Setting.site_name}] Neue Quelle eingesendet",
      to: Setting.email,
      reply_to: email,
      from: Setting.get('from'),
    }
  end
end
