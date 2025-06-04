module EmailObfuscatorHelper
  def obfuscated_email_tag(email, options = {})
    return "" if email.blank?

    # Reverse the email and then base64 encode it for obfuscation
    encoded_email = Base64.strict_encode64(email.reverse)

    # Default options
    options[:delay] ||= 300
    options[:placeholder] ||= email.gsub('@', ' [at] ').gsub('.', ' [punkt] ')
    options[:class] ||= ''

    # Build the data attributes
    data_attrs = {
      controller: 'email-obfuscator',
      'email-obfuscator-encoded-value': encoded_email,
      'email-obfuscator-delay-value': options[:delay]
    }

    # Add click action if copy functionality is desired
    if options[:copyable]
      data_attrs[:action] = 'click->email-obfuscator#copyEmail'
    end

    content_tag :span,
                data: data_attrs,
                class: "email-obfuscator #{options[:class]}".strip do
      content_tag :span, options[:placeholder],
                  data: { 'email-obfuscator-target': 'email' },
                  class: 'email-placeholder'
    end
  end

  def obfuscate_emails_in_html(html)
    return html if html.blank?

    # List of emails to obfuscate - specific to this application
    emails = [
      'info@pludoni.de',
      'datenschutz@pludoni.de',
      'beratung@pludoni.de',
      'info@hrfilter.de',
      'info@fahrrad-filter.de'
    ]

    obfuscated_html = html.dup

    emails.each do |email|
      placeholder = email.gsub('@', ' [at] ').gsub('.', ' [punkt] ')
      obfuscated_html = obfuscated_html.gsub(email) do |_match|
        obfuscated_email_tag(email, placeholder:)
      end
    end

    obfuscated_html.html_safe
  end
end
