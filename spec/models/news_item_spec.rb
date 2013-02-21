require 'spec_helper'

describe NewsItem do

  let(:item) { NewsItem.new(url: "http://stefanwienert.net/blog/2013/02/08/faster-rails-tests-with-spring-faster-than-spork-und-easier-to-setup/")
  }
  describe "Fetcher" do
    specify "Twitter" do
      Fetcher.stub :fetch_url => OpenStruct.new(code: 200, body: { count: 5 }.to_json)
      item.fetch_twitter
      item.retweets.should == 5
    end
    specify "Facebook" do
      Fetcher.stub :fetch_url => OpenStruct.new(code: 200, body: "[{\"url\":\"http:\\/\\/bing.com\",\"like_count\":36,\"total_count\":110,\"share_count\":69,\"click_count\":0}]")
      item.fetch_facebook
      item.fb_likes.should == 110
    end
    specify "Linkedin" do
      Fetcher.stub :fetch_url => OpenStruct.new(code: 200, body: 'IN.Tags.Share.handleCount({"count":174,"fCnt":"174","fCntPlusOne":"175","url":"http:\/\/developer.linkedin.com\/share-plugin"});')
      item.fetch_linkedin
      item.linkedin.should == 174
    end
  end

  describe "Score" do
    let(:item) { NewsItem.new(
      url: "http://stefanwienert.net/blog/2013/02/08/faster-rails-tests-with-spring-faster-than-spork-und-easier-to-setup/",
      retweets: 10,
      source: Source.new(value: 10),
      published_at: Time.now,
      xing: 10,
      fb_likes: 10,
      linkedin: 10
    )
    }

    specify "Verliert jede Stunde Aktualitaet" do
      base = item.score
      base.should > 0
      item.published_at = 10.days.ago
      item.score.should == 0

      item.published_at = 5.days.ago
      item.score.should be_within(1).of(base * 0.5 )
    end
  end

  describe "Import" do
    let(:feed_source) {FeedSource.create!(url: "...", name: "..") }
    specify "legt an - mit original url", freeze_time: "2013-02-01 12:00:00"  do
      VCR.use_cassette "or-redirect-with-google-utm" do
        NewsItem.process({
          source: feed_source,
          title: "BLAH",
          guid: "asd",
          url: "http://feedproxy.google.com/~r/OnlineRecruiting/~3/iFBX-7Sdvgw/",
          text: "BLABLABLABLABLABLABLABLALBALBALBA",
          published: 1.hour.ago
        })

        NewsItem.first.tap do |i|
          i.should be_present
          i.url.should == "http://www.online-recruiting.net/der-hr-agentur-atlas-2013-spendenprojekt-gesucht/"
          i.published_at.should == 1.hour.ago
        end
      end
    end
    specify "Aktualisiert - aber nicht published_at", freeze_time: "2013-02-01 12:00:00" do
      VCR.use_cassette "or-redirect-with-google-utm" do
        NewsItem.process({
          source: feed_source,
          title: "BLAH",
          guid: "asd",
          url: "http://feedproxy.google.com/~r/OnlineRecruiting/~3/iFBX-7Sdvgw/",
          text: "BLABLABLABLABLABLABLABLALBALBALBA",
          published: 5.hour.ago
        })
        NewsItem.process({
          source: feed_source,
          title: "BLAH2",
          guid: "asd",
          url: "http://feedproxy.google.com/~r/OnlineRecruiting/~3/iFBX-7Sdvgw/",
          text: "BLABLABLABLABLABLABLABLALBALBALBA",
          published: 1.hour.ago
        })

        NewsItem.first.tap do |i|
          i.published_at.should == 5.hour.ago
          i.title.should == "BLAH2"
        end
      end

    end
  end

end
