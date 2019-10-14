describe MailSubscriptionsController do
  before do
    Rails.cache.clear
  end

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

  specify 'newsletter after subscription after 9am Monday', freeze_time: '2019-10-18 12:00' do
    VCR.use_cassette 'events' do
      ms = MailSubscription.create!(subscription)
      post :confirm, params: { id: ms.token }
      expect(ms.reload.confirmed?).to be == true
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  specify 'no newsletter after subscription on Monday before 9am', freeze_time: "2017-11-06 8:00" do
    VCR.use_cassette 'events' do
      ms = MailSubscription.create!(subscription)
      post :confirm, params: { id: ms.token }
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
