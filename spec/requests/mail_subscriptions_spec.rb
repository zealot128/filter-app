require 'spec_helper'


describe 'MailSubscriptionsController' do
  specify 'Anlegen' do
    get '/newsletter'
    assert(response.success?)
    c = Category.create!(name: 'Recruiting', keywords: 'Headhunter')

    post '/newsletter', mail_subscription: {
      email: 'stwienert@gmail.com',
      interval: 'weekly',
      categories: [ c.id ]
    }
    assert(response.success?)
    expect(ActionMailer::Base.deliveries.count).to be == 1
    body = ActionMailer::Base.deliveries.first.body.to_s
    url = Nokogiri::HTML.fragment(body).at('a')['href']

    get URI.parse(url).path
    assert(response.success?)

    MailSubscription.first.tap do |s|
      expect(s.email).to be == 'stwienert@gmail.com'
      expect(s.confirmed).to be == true
    end
  end

end
