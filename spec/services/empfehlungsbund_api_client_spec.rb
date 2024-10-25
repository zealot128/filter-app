describe EmpfehlungsbundAPIClient do
  before do
    Rails.cache.clear
  end

  specify 'Partner Events' do
    VCR.use_cassette 'eb_api_client/partner_events' do
      events = EmpfehlungsbundAPIClient.partner_events
      expect(events.count).to be > 3
      event = events.first
      expect(event.url).to be_present
      expect(event.from).to be_present
    end
  end

  specify 'Community Events', freeze_time: "2017-08-01 12:00" do
    VCR.use_cassette 'eb_api_client/community_events' do
      events = EmpfehlungsbundAPIClient.community_events
      expect(events.count).to be >= 1
      event = events.first
      expect(event.url).to be_present
      expect(event.from).to be_present
    end
  end
end
