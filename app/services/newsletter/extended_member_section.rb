module Newsletter
  class ExtendedMemberSection
    def initialize(mailing)
      @mailing = mailing
      load_feed_items
    end

    def to_partial_path
      "newsletter_mailer/extended_member_section"
    end

    def load_feed_items
      # TODO: since last sent
      @items = AdLogic.third_party_news.
        # where('published_at > ?', 3.months.ago)
        where('published_at > ? and published_at <= ?', *@mailing.interval)
    end

    def anchor
      "extended_section"
    end

    def toc_title
      AdLogic.toc_title
    end

    def news_items
      @items
    end
  end
end
