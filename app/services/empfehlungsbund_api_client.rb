class EmpfehlungsbundApiClient
  include HTTParty
  base_uri 'api.empfehlungsbund.de/api/v2'

  def self.partner_events
    response = Rails.cache.fetch('partner_events', expires_in: 1.hour) do
      events = get('/partner_events.json')
      events.select{|i| i['event_type'] != 'profession' && Time.zone.parse(i['from']) <= 3.months.from_now }
    end
    response.map do |hash|
      PartnerEvent.new(hash)
    end
  end

  def self.community_events
    response = Rails.cache.fetch('events', expires_in: 1.hour) do
      events = get('/community_trainings.json')
      events.select{|i| Time.zone.parse(i['start']) <= 4.months.from_now }
    end
    response.map do |hash|
      CommunityEvent.new(hash)
    end
  end


  class PartnerEvent
    attr_accessor :id, :title, :body, :link, :from, :to, :address, :event_type, :image
    def initialize(args)
      args.each do |k,v|
        self.instance_variable_set("@#{k}", v)
      end
    end

    def url
      "http://login.empfehlungsbund.de/partner_events/#{id}?utm_medium=email&utm_source=hrfilter&utm_campaign=hrfilter_newsletter"
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
      "http://login.empfehlungsbund.de/events/#{id}?utm_medium=email&utm_source=hrfilter&utm_campaign=hrfilter_newsletter"
    end
  end

end
