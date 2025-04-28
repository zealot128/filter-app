class SubmitSource < MailForm::Base
  attribute :url, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :comment

  BLOCKLIST = Regexp.union([
    /graph\.org/,
    /\.(ru|ua|by|kz|in)$/,
    /testing-your-form.info/,
    /wikidoc/,
    /example.com/
  ])

  def deliver
    return false unless valid?

    if url.to_s[BLOCKLIST] && email.to_s[BLOCKLIST] && comment.to_s[BLOCKLIST]
      return true
    end

    super
  end

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
