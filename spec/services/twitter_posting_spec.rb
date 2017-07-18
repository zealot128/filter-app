require 'spec_helper'

describe TwitterPosting do
  specify 'run' do
    Setting.set('twitter_access_token', '123')
    expect_any_instance_of(Twitter::REST::Client).to receive(:update).and_return(OpenStruct.new(id: 123))
    ni = Fabricate(:news_item, xing: 100, retweets: 100, published_at: 2.hours.ago)
    expect(ni.absolute_score).to be > 20
    TwitterPosting.cronjob
    expect(ni.reload.tweet_id).to be == "123"
  end
end
