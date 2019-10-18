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
end
