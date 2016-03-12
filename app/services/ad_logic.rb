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
