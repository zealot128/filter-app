class AdLogic
  class << self
    def enabled?
      Setting.key == 'hrfilter'
    end

    def events
      (EmpfehlungsbundApiClient.community_events + EmpfehlungsbundApiClient.partner_events).sort_by{|i| i.from }
    end

    def third_party_news
      Source.find(Setting.promoted_feed_id).news_items
    end

    def toc_title
      "Empfehlungsbund News"
    end

    def twitter_news(interval)
      NewsItem.
        where(source_id: FeedSource.visible.where(language: 'german').select('id')).
        where('published_at > ?', interval).
        where('absolute_score > 20').
        order('absolute_score desc').
        limit(3)
    end

  end
end
