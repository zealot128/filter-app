# include into mail-sending scenarios

module MailHelper
  extend ActiveSupport::Concern

  included do
    after(:each) do
      ActionMailer::Base.deliveries.each do |mail|
        if mail.body.to_s[/translation missing: (.*)"/]
          fail "There are missing translations: #{Regexp.last_match(1)}"
        end
        if begin
              mail.body.parts.first.to_s[/translation missing: (.*)"/]
            rescue
              false
            end
          fail "There are missing translations: #{Regexp.last_match(1)}"
        end
      end
    end
    let(:mail) { ActionMailer::Base.deliveries.last }
    let(:mails) { ActionMailer::Base.deliveries }
    let(:multi_part_body) { mail.body.parts.first.to_s }
  end
end
