class AdLogic
  class << self
    def enabled?
      Setting.key == 'hrfilter' && Setting.get('promoted_feed_id').present? && Setting.get('promoted_feed_id') != 0
    end

    def events
      EmpfehlungsbundAPIClient.partner_events.sort_by(&:from).take(6)
    end

    def promoted_events
      EmpfehlungsbundAPIClient.community_events
    end

    def third_party_news
      Source.find(Setting.get('promoted_feed_id')).news_items
    end

    def toc_title
      "Empfehlungsbund News"
    end

    def twitter_news(from, to)
      NewsItem.
        where(source_id: FeedSource.visible.where(language: 'german').select('id')).
        where('published_at between ? and ?', from, to).
        where('absolute_score > 20').
        order('absolute_score desc').
        limit(4)
    end
  end
end
