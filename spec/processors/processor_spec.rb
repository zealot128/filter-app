require "spec_helper"
describe Processor, type: :model do
  let(:feed_source) {FeedSource.new(url: "...", name: "..") }

  specify "legt an - mit original url", freeze_time: "2013-11-02 12:00:00"  do
    VCR.use_cassette "feed-url" do
      feed_source.url = 'http://www.online-recruiting.net/feed/'
      feed_source.full_text_selector = '.entry-content'
      feed_source.save
      Processor.process(feed_source)
      NewsItem.first.tap do |i|
        i.should be_present
        i.url.should == "http://www.online-recruiting.net/hr-tech-startup-investments-im-mai/"
        i.full_text.should be_present
      end
    end
  end

  specify 'teaser respects html entities' do
    text = "I can't believe I missed this a few years ago."
    Processor.new.teaser(text).should be ==  "I can't believe I missed this a few years ago."
  end

  specify 'Crosswater', freeze_time: '2013-11-02 12:00' do
    VCR.use_cassette 'feed-crosswater' do
      feed_source.url = 'http://crosswater-job-guide.com/feed'
      feed_source.full_text_selector = '.art-PostContent:nth-child(3)'
      feed_source.save
      Processor.process(feed_source)
      NewsItem.first.full_text.length.should > 200
    end
  end

  specify 'Reddit' do
    VCR.use_cassette 'reddit-1', record: :new_episodes do
      rs = RedditSource.create!(name: 'bicycling')
      rs.refresh
      rs.news_items.count.should be > 10
    end
  end

end
