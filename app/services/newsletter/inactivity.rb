module Newsletter
  class Inactivity
    REMINDERS = [
      { time: 14.days, key: 'reminder_mail_14_days_' },
      { time: 3.days, key: 'reminder_mail_3_days_' },
      { time: 1.day, key: 'reminder_mail_1_days_' },
    ].freeze

    def self.reminders
      REMINDERS.map { |step|
        {
          subject: Setting.get("#{step[:key]}subject"),
          body: Setting.get("#{step[:key]}body"),
          time: step[:time],
        }
      }
    end

    def self.cronjob
      return if Setting.get('inactive_months').blank?

      MailSubscription.confirmed.each do |s|
        new(s).run
      end
    end

    def initialize(mail_subscription)
      @mail_subscription = mail_subscription
    end

    def run
      return if clicked_in_time_frame?

      if shall_unsubscribe_now?
        # nicht an 2 aufeinanderfolgenden Tagen
        return if @mail_subscription.last_reminder_sent_at >= 1.day.ago.to_date
        email = SubscriptionMailer.unsubscribe_mail(@mail_subscription,
                                                    subject: replace_tokens(Setting.get('reminder_unsubscribe_notice_subject')),
                                                    body: replace_tokens(Setting.get('reminder_unsubscribe_notice_body')))
        @mail_subscription.destroy
        email.deliver_now

      elsif can_receive_next_reminder?

        send_next_reminder!
        @mail_subscription.assign_attributes(
          number_of_reminder_sent: @mail_subscription.number_of_reminder_sent + 1,
          last_reminder_sent_at: Time.zone.today
        )
        @mail_subscription.save validate: false
      end
    end

    private

    def shall_unsubscribe_now?
      number_of_reminder == max_reminder && unsubscribe_on.to_date <= Time.zone.today
    end

    def unsubscribe_on
      last_click_date + Setting.get('inactive_months').to_i.months
    end

    def last_click_date
      [@mail_subscription.created_at, @mail_subscription.histories.maximum(:opened_at)].compact.max
    end

    def clicked_in_time_frame?
      (unsubscribe_on - 14.days).to_date > Time.zone.today
    end

    def can_receive_next_reminder?
      if @mail_subscription.last_reminder_sent_at && @mail_subscription.last_reminder_sent_at == Time.zone.today
        return false
      end
      return false if !next_mail

      (unsubscribe_on - next_mail[:time].days).to_date <= Time.zone.today
    end

    def max_reminder
      self.class.reminders.length
    end

    def next_mail
      self.class.reminders[number_of_reminder]
    end

    def send_next_reminder!
      next_mail = self.class.reminders[number_of_reminder]

      body = replace_tokens(next_mail[:body])
      subject = replace_tokens(next_mail[:subject])

      SubscriptionMailer.reconfirm_mail(@mail_subscription, subject: subject, body: body).deliver_now
    end

    def number_of_reminder
      @mail_subscription.number_of_reminder_sent
    end

    def replace_tokens(text)
      text.gsub(/{{([^}]+)}}/) do |_|
        token(Regexp.last_match(1))
      end
    end

    def token(match) # rubocop:disable Metrics/CyclomaticComplexity
      case match.downcase.strip
      when 'anmeldedatum'
        I18n.l(@mail_subscription.created_at.to_date)

      when 'link'
        Rails.application.routes.url_helpers.reconfirm_mail_subscription_url(id: @mail_subscription.token, host: Setting.host, protocol: 'https')

      when 'letzte-oeffnung'
        I18n.l(last_click_date)

      when 'abbestellen-link'
        Rails.application.routes.url_helpers.edit_mail_subscription_url(@mail_subscription.token, host: Setting.host, protocol: 'https')

      when 'loeschdatum'
        d = if number_of_reminder == 0
              14.days.from_now
            elsif number_of_reminder == 1
              3.days.from_now
            else
              unsubscribe_on
            end
        I18n.l(d.to_date)

      when 'wochen'
        ((Time.zone.today - last_click_date.to_date) / 7).floor

      when 'subscribe-link'
        Rails.application.routes.url_helpers.mail_subscriptions_url(host: Setting.host, protocol: 'https')

      else
        raise NotImplementedError, "Unknown token: #{match}"
      end
    end
  end
end
