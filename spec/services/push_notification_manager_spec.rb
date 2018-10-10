require 'fcm'

RSpec.describe PushNotificationManager, type: :service do
  specify 'pushes new notification' do
    source = Fabricate(:source)
    news_item = Fabricate(:news_item, source: source)
    manager = PushNotificationManager.new(
      fcm_token: '123',
      subscribed_sourced: [source.id]
    )
    expect(manager.next_unread_entry).to be == news_item

    expect_any_instance_of(FCM).to receive(:send).and_return(status_code: 200, body: { 'failure' => 0, 'success' => 1 }.to_json)
    manager.run

    expect(PushNotification.count).to be == 1
  end

  specify 'reposting' do
    source = Fabricate(:source)
    _news_item = Fabricate(:news_item, source: source)
    manager = PushNotificationManager.new(
      fcm_token: '123',
      subscribed_sourced: [source.id]
    )
    expect_any_instance_of(FCM).to receive(:send).and_return(status_code: 200, body: { 'failure' => 0, 'success' => 1 }.to_json)
    manager.run
    manager.run

    expect(PushNotification.count).to be == 1
  end

  specify 'throttling' do
    source = Fabricate(:source)
    Fabricate(:news_item, source: source)
    Fabricate(:news_item, source: source, guid: '123')

    manager = PushNotificationManager.new(
      fcm_token: '123',
      subscribed_sourced: [source.id]
    )
    allow_any_instance_of(FCM).to receive(:send).and_return(status_code: 200, body: { 'failure' => 0, 'success' => 1 }.to_json)

    manager.run
    manager.run

    expect(PushNotification.count).to be == 1
    Timecop.travel 6.hours.from_now do
      manager.run
      expect(PushNotification.count).to be == 2
    end
  end

  specify 'not post again if NotRegistered' do
    source = Fabricate(:source)
    Fabricate(:news_item, source: source)
    manager = PushNotificationManager.new(
      fcm_token: '123',
      subscribed_sourced: [source.id]
    )

    expect_any_instance_of(FCM).to receive(:send).and_return(
      status_code: 200,
      body: { 'failure' => 1, 'success' => 1, 'results' => [{ 'error' => 'NotRegistered' }] }.to_json
    )

    manager.run

    expect(PushNotification.device_unregistered.count).to be == 1

    Fabricate(:news_item, source: source, guid: '123')
    Timecop.travel 6.hours.from_now do
      manager.run
      expect(PushNotification.count).to be == 1
    end
  end
end
