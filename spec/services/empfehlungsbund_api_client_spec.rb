require 'spec_helper'

describe EmpfehlungsbundApiClient do
  specify 'Partner Events' do
    VCR.use_cassette 'eb_api_client/partner_events' do
      events = EmpfehlungsbundApiClient.partner_events
      expect(events.count).to be > 3
      event = events.first
      expect(event.url).to be_present
      expect(event.from).to be_present
    end
  end

  specify 'Community Events' do
    # TODO Test durchführen wenn, ein Commutiy Event ansteht
    skip "Keine kommenden Events aufgezeichnet" do
      VCR.use_cassette 'eb_api_client/community_events', record: :new_episodes do
        events = EmpfehlungsbundApiClient.community_events
        events.select { |i| i['visible'] && i['start'] >= Time.zone.now.to_s }
        expect(events.count).to be >= 1
        event = events.first
        expect(event.url).to be_present
        expect(event.from).to be_present
      end
    end
  end
end
