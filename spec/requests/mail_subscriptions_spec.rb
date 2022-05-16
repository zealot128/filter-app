describe 'MailSubscriptionsController' do
  before(:each) do
    Sidekiq::Testing.inline!
  end

  specify 'Embed' do
    get '/newsletter/embed'
    expect(response).to be_successful
  end

  specify 'Anlegen' do
    VCR.use_cassette 'events' do
      get '/newsletter'
      assert(response.successful?)
      c = Category.create!(name: 'Recruiting', keywords: 'Headhunter')
      
      post '/newsletter', params: {
        mail_subscription: {
          first_name: 'Stefan',
          last_name: 'Wienert',
          email: 'stwienert@gmail.com',
          interval: 'weekly',
          limit: 50,
          categories: [c.id],
          privacy: 1
        }
      }
      
      expect(response.redirect?).to be == true
      expect(ActionMailer::Base.deliveries.count).to be == 1
      body = ActionMailer::Base.deliveries.first.html_part.body.to_s
      url = Nokogiri::HTML.fragment(body).at('a')['href']

      get URI.parse(url).path
      assert(response.successful?)

      MailSubscription.first.tap do |s|
        expect(s.email).to be == 'stwienert@gmail.com'
        expect(s.status).to be == 'confirmed'
      end
    end
  end

  describe 'Versenden' do
    let(:subscription) {
      MailSubscription.create!(
        first_name: 'Stefan',
        last_name: 'Wienert',
        email: 'stwienert@gmail.com',
        categories: [category.id],
        limit: 50,
        interval: 'weekly'
      )
    }
    let(:category) {
      Category.create!(name: 'Gehalt', keywords: '')
    }
    specify 'tracks send status so no duplicate send' do
      VCR.use_cassette 'events' do
        subscription.confirm!

        # Keine Mail, wenn nichts neues
        Newsletter::Mailing.cronjob
        expect(ActionMailer::Base.deliveries.count).to eq(0)

        import_stuff!
        # 1 news da, mail geht raus
        Newsletter::Mailing.cronjob
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(MailSubscription::History.count).to be == 1
        expect(ActionMailer::Base.deliveries.first.html_part.decoded).to include MailSubscription::History.first.open_token

        tracking_url = Nokogiri::HTML.parse(ActionMailer::Base.deliveries.first.html_part.decoded).search('img').last['src']
        get tracking_url
        expect(response).to be_successful
        expect(response.media_type).to be == 'image/png'
        expect(MailSubscription::History.opened.count).to be == 1

        # nochmal ausgefuehrt -> geht nicht, da Datum gesetzt
        Newsletter::Mailing.cronjob
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        Timecop.travel 7.days.from_now
        Newsletter::Mailing.cronjob
        # Keine neuen News
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        @ni.update_columns published_at: 2.days.ago
        Newsletter::Mailing.cronjob
        expect(ActionMailer::Base.deliveries.count).to eq(2)

        # Klick = auch geoeffnet
        tracking_link = Nokogiri.parse(ActionMailer::Base.deliveries.last.html_part.body.decoded).search('a').map { |i| i['href'] }.grep(%r{/ni/}).first
        get tracking_link.remove(%r{http://[^/]+})

        expect(MailSubscription::History.opened.count).to be == 2
        expect(MailSubscription::History.last.click_count).to be == 1
        Timecop.return
      end
    end

    specify 'adds newly added categories, even if not subscribed' do
      VCR.use_cassette 'events' do
        subscription.confirm!
        import_stuff!

        Category.create!(name: 'NewCategoryOk', keywords: '')
        Category.create!(name: 'NewCategoryTooOld', keywords: '', created_at: 14.days.ago)
        Newsletter::Mailing.cronjob
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        body = ActionMailer::Base.deliveries.first.html_part.body.to_s
        expect(body).to include "NewCategoryOk"
        expect(body).to_not include "NewCategoryTooOld"
      end
    end

    def import_stuff!
      allow_any_instance_of(NewsItem).to receive(:refresh)
      VCR.use_cassette 'feed-pludoni.xml' do
        source = FeedSource.create!(url: 'http://www.pludoni.de/posts/feed.rss', name: 'pludoni')
        source.refresh
        expect(source.news_items.count).to be > 0
        @ni = source.news_items.first
        @ni.categories << category
        @ni.update_columns absolute_score: 100, published_at: 2.days.ago
      end
    end
  end
end
