describe MailSubscription do
  specify 'destroy archives' do
    ms = MailSubscription.create!(gender: 'male', interval: 'weekly', categories: [1], extended_member: true, email: 'info@example.com', status: 'confirmed', first_name: 'John', last_name: 'M', company: 'FOOBAR', limit: 50)

    expect(MailSubscription.confirmed.first).to be == ms

    ms.destroy

    # 1. not confirmed anymore
    expect(MailSubscription.confirmed.first).to be == nil

    # 2. but still there
    expect(MailSubscription.count).to be == 1
    ms.reload
    expect(ms.deleted_at).to be_present
  end
end
