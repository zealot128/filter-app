require 'spec_helper'

describe MailSubscriptionsController do
  let(:subscription) {
    {
      email: 'stwienert@gmail.com',
      categories: [category.id],
      limit: 50,
      interval: 'weekly'
    }
  }
  let(:category) {
    Category.create!(name: 'Recruiting', keywords: 'Headhunter')
  }

  specify 'newsletter after subscription after 9am Monday' do
    ms = MailSubscription.create!(subscription)
    post :confirm, id: ms.token
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  specify 'no newsletter after subscription on Monday before 9am' do
    Timecop.travel(Time.zone.local(2017, 11, 6, 8, 0, 0)) do
      ms = MailSubscription.create!(subscription)
      post :confirm, id: ms.token
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
