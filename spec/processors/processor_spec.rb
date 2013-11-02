require "spec_helper"
describe Processor do
  let(:feed_source) {FeedSource.create!(url: "...", name: "..") }

  specify "legt an - mit original url", freeze_time: "2013-11-02 12:00:00"  do
    VCR.use_cassette "feed-url" do
      feed_source.url = 'http://www.online-recruiting.net/feed/'
      feed_source.full_text_selector = '#singlepage'
      Processor.process(feed_source)
      NewsItem.first.tap do |i|
        i.should be_present
        i.url.should == "http://www.online-recruiting.net/7-fragen-an-jobs-automobilwoche-de-das-portrait/"
        i.full_text.should be_present
      end
    end
  end

  specify "Haufe.de", freeze_time: "2013-11-02 12:00:00"  do
    VCR.use_cassette "feed-urlhaufe" do
      feed_source.url = 'https://www.haufe.de/xml/rss_129150.xml'
      feed_source.full_text_selector = '#col1_content .floatbox'
      Processor.process(feed_source)
      binding.pry
      NewsItem.first.tap do |i|
        i.should be_present
        i.url.should == "http://www.online-recruiting.net/7-fragen-an-jobs-automobilwoche-de-das-portrait/"
        i.full_text.should be_present
      end
    end
  end

end
