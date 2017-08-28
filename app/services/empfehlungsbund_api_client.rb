class EmpfehlungsbundApiClient
  include HTTParty
  base_uri 'api.empfehlungsbund.de/api/v2'

  def self.partner_events
    response = Rails.cache.fetch('partner_events', expires_in: 1.hour) do
      events = get('/partner_events.json')
      events.select { |i| i['event_type'] != 'profession' && Time.zone.parse(i['from']) <= 3.months.from_now }
    end
    response.map do |hash|
      PartnerEvent.new(hash)
    end
  end

  def self.community_events
    response = Rails.cache.fetch('events', expires_in: 1.minute) do
      events = get('https://crm.pludoni.com/api/community_workshops.json')
      events.select { |i| i['visible'] && i['start'] >= Time.zone.now.to_s && i['start'] <= 3.months.from_now.to_s }
    end
    response.map do |hash|
      CommunityEvent.new(hash)
    end
  end

  class PartnerEvent
    attr_accessor :id, :title, :body, :link, :from, :to, :address, :event_type, :image
    def initialize(args)
      args.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def url
      "https://login.empfehlungsbund.de/partner_events/#{id}?utm_medium=email&utm_source=hrfilter&utm_campaign=hrfilter_newsletter"
    end

    def from
      Time.zone.parse(@from)
    end
  end

  class CommunityEvent < PartnerEvent
    def from
      Time.zone.parse(@start)
    end

    def url
      "#{@show_url}?utm_medium=email&utm_source=hrfilter&utm_campaign=hrfilter_newsletter"
    end

    def to
      Time.zone.parse(@finish)
    end

    def link
      url
    end

    def body
      @teaser_hrfilter || @teaser
    end

    def image
      @banner_hrfilter || @banner
    end
  end
end
