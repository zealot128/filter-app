describe BaseProcessor, type: :model do
  let(:feed_source) { FeedSource.new(url: "...", name: "..") }
  include_context 'active_job_inline'

  specify "legt an - mit original url", freeze_time: "2013-11-02 12:00:00" do
    VCR.use_cassette "feed-url", record: :new_episodes do
      feed_source.url = 'http://www.online-recruiting.net/feed/'
      feed_source.full_text_selector = '.entry-content'
      feed_source.save
      Sidekiq::Testing.inline! do
        BaseProcessor.process(feed_source)
      end
      NewsItem.first.tap do |i|
        expect(i).to be_present
        expect(i.url).to eq("http://www.online-recruiting.net/hr-tech-startup-investments-im-mai/")
        expect(i.full_text).to be_present
      end
    end
  end

  specify 'teaser respects html entities' do
    text = "I can't believe I missed this a few years ago."
    expect(BaseProcessor.new.teaser(text)).to eq("I can't believe I missed this a few years ago.")
  end

  specify 'Crosswater', freeze_time: '2013-11-02 12:00' do
    VCR.use_cassette 'feed-crosswater' do
      feed_source.url = 'http://crosswater-job-guide.com/feed'
      feed_source.full_text_selector = '.art-PostContent:nth-child(3)'
      feed_source.save

      allow_any_instance_of(NewsItem).to receive(:refresh)

      Sidekiq::Testing.inline! do
        BaseProcessor.process(feed_source)
      end
      expect(NewsItem.first.full_text.length).to be > 200
    end
  end

  specify 'Paywall', freeze_time: '2020-07-01 12:00' do
    news_item = NewsItem.create(
      title: "...",
      source: feed_source,
      url: "https://www.manager-magazin.de/premium/herbert-diess-bei-volkswagen-die-strafe-fuer-sein-auftreten-a-b5fb474e-7e6b-4dfa-8d7d-5da06a8c2452"
    )
    feed_source.update(full_text_selector: 'article')

    VCR.use_cassette "paywall/mm", record: :new_episodes do
      news_item.get_full_text
      expect(news_item.paywall).to be == true
    end
  end
end
