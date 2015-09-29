require 'spec_helper'

describe NewsItem do

  let(:like_fetcher) { NewsItem::LikeFetcher.new("http://stefanwienert.net/blog/2013/02/08/faster-rails-tests-with-spring-faster-than-spork-und-easier-to-setup/") }

  describe "Fetcher" do
    specify "Twitter" do
      Fetcher.stub :fetch_url => OpenStruct.new(code: 200, body: { count: 5 }.to_json)
      like_fetcher.tweets.should == 5
    end
    specify "Linkedin" do
      Fetcher.stub :fetch_url => OpenStruct.new(code: 200, body: 'IN.Tags.Share.handleCount({"count":174,"fCnt":"174","fCntPlusOne":"175","url":"http:\/\/developer.linkedin.com\/share-plugin"});')
      like_fetcher.linkedin.should == 174
    end
  end

end
