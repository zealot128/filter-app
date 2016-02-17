require 'spec_helper'

describe NewsItem do
  describe "Like-Fetcher" do
    let(:like_fetcher) { NewsItem::LikeFetcher.new("http://stefanwienert.net/blog/2013/02/08/faster-rails-tests-with-spring-faster-than-spork-und-easier-to-setup/") }

    specify "Twitter" do
      ni = NewsItem.new(retweets: nil)
      like_fetcher.stub twitter_search: OpenStruct.new(count: 1)
      like_fetcher.maybe_update_tweets(ni)
      ni.retweets.should == 1
    end
    specify "Linkedin" do
      Fetcher.stub fetch_url: OpenStruct.new(code: 200, body: 'IN.Tags.Share.handleCount({"count":174,"fCnt":"174","fCntPlusOne":"175","url":"http:\/\/developer.linkedin.com\/share-plugin"});')
      like_fetcher.linkedin.should == 174
    end
  end

  describe "Categorizer" do
    specify "Default assigns keywords" do
      c1 = Fabricate(:category, keywords: 'gehalt,bwl')
      c2 = Fabricate(:category, keywords: 'foobar')

      ni = Fabricate.build(:news_item, title: 'Gehalt bla')
      ni.source.default_category = c2
      ni.categorize
      ni.categories.sort_by{|i| i.id}.should be == [c1,c2]

      ni.source.default_category = nil
      ni.categorize
      ni.categories.should be == [c1]
    end
  end
end
