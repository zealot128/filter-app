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

  end
end
