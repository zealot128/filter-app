module Newsletter
  class Mailing
    attr_reader :subscription, :new_categories
    attr_accessor :from

    def self.cronjob
      MailSubscription.confirmed.each do |s|
        ms = new(s)
        next unless ms.sendable?

        secs = rand(5..360)
        NewsletterWorker.perform_in(secs, s.id)
      end
    end

    def initialize(subscription, from: subscription.interval_from.ago)
      @subscription = subscription
      @from = from
    end

    def sendable?
      sections.any? && subscription.due?
    end

    def salutation
      @subscription.salutation
    end

    def subject
      kw = Date.today.strftime("%W").to_i
      top_news_items = sections.
        flat_map { |i| i.respond_to?(:news_items) ? i.news_items : [] }.
        sort_by { |i|
          source = i.source.value || 1
          -(i.value / source * Math.log([source, 8].min))
        }.
        take(3)
      if top_news_items.none?
        return "[#{Setting.site_name}] KW #{kw} - #{count} Beiträge"
      end

      subjects = []
      top_news_items.each do |item|
        truncated = item.title.truncate(60)
        subjects << truncated
        if subjects.join.length >= 120
          break
        end
      end
      title = subjects.map { |i| %{"#{i}"} }.to_sentence

      "#{title} - HRfilter KW #{kw}"
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def intro
      Setting.mail_intro.gsub(/\{\{([^\}]+)\}\}/) do |pattern|
        case $1.strip
        when 'top' then count.to_s
        when 'total_count' then total_count.to_s
        when 'from_interval', 'interval_from'
          case subscription.interval
          when 'weekly' then 'der letzten Woche'
          when 'monthly' then 'des letzten Monats'
          when 'biweekly' then 'der letzten zwei Wochen'
          end
        when 'categories' then categories.map(&:name).to_sentence
        else "missing_token #{pattern}"
        end
      end
    end

    def outro
      Setting.mail_outro.gsub(/\{\{([^\}]+)\}\}/) do |pattern|
        case Regexp.last_match(1).strip
        when 'person_email' then Setting.get_value("person_email")
        when 'person' then Setting.get_value("person")
        when 'abmelde_link'
          if subscription.persisted?
            Rails.application.routes.url_helpers.edit_mail_subscription_url subscription, host: Setting.host, protocol: 'https'
          else
            "https://#{Setting.host}/newsletter/"
          end
        else "missing_token #{pattern}"
        end
      end
    end

    def send!
      history = create_mailing_history!
      mail(history.open_token).deliver_now!
    rescue StandardError => e
      history.try(:delete)
      raise e if Rails.env.test?
      NOTIFY_EXCEPTION(e)
      Rails.logger.error "[NewsletterMailing] #{e.inspect}"
    ensure
      subscription.update_column :last_send_date, Time.zone.today
    end

    def mail(history_token)
      @mail ||= NewsletterMailer.newsletter(self, history_token)
    end

    def create_mailing_history!
      @subscription.histories.create(news_items_in_mail: count)
    end

    def full_email
      @subscription.full_email
    end

    def sections
      @sections ||=
        begin
          s = []
          categories.each do |cat|
            s << CategorySection.new(cat, self)
          end

          all_news_items = s.flat_map(&:news_items).sort_by { |i| -(i.absolute_score || 0) }.uniq(&:title)
          @total_count = all_news_items.count
          filtered_news_items = all_news_items.take(@subscription.limit || 100)
          s.each do |section|
            section.news_items = section.news_items.select { |ni| filtered_news_items.include?(ni) }
          end

          # uniq filtern
          already_checked = []
          s.sort_by { |i| i.news_items.count }.each do |section|
            section.news_items = section.news_items - already_checked
            already_checked += section.news_items
          end
          s.reject! { |i| i.news_items.count == 0 }
          @new_categories = Category.where('created_at between ? and ?', *interval) - categories
          # Werbeblock
          if AdLogic.enabled?
            section = ExtendedMemberSection.new(self)
            if section.news_items.any?
              s.prepend(section)
            end
          end
          s
        end
      # Alle News-Items bilden
    end

    def categories
      @categories ||= begin
                        category_ids = @subscription.categories.reject(&:blank?)
                        base = Category.where(id: category_ids).to_a
                        if has_uncatorized?
                          base + [Uncategorized.new]
                        else
                          base
                        end
                      end
    end

    def count
      sections.map { |i| i.respond_to?(:news_items) ? i.news_items.count : 0 }.sum
    end

    def total_count
      @total_count
    end

    def has_uncatorized?
      @subscription.categories.include? 0
    end

    def interval
      to = from + subscription.interval_from
      [from, to]
    end
  end
end
