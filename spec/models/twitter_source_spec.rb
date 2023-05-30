require 'link_extractor'
RSpec.describe TwitterSource do
  # NOTE:
  # To rerun without cassette set valid twitter creds and anonymize afterwards in spec/fixtures/vcr_cassettes/*.yml
  # Rails.application.secrets.twitter_consumer_key = "xxxx"
  # Rails.application.secrets.twitter_consumer_secret = "xxxx"
  # Setting.set('twitter_access_token', "xxxx")
  # Setting.set('twitter_access_secret', "xxxx")
  before(:each) do
    Setting.set('twitter_access_token', Rails.application.secrets.twitter_access_token.presence || "aaa")
    Setting.set('twitter_access_secret', Rails.application.secrets.twitter_access_secret.presence || "bbb")
  end
  specify 'twitter personalwirtschaft' do

    allow_any_instance_of(LinkExtractor).to receive(:image_blob).and_return(nil)
    VCR.use_cassette 'personalwirtschaft' do
      source = TwitterSource.new(url: 'personaler_de', name: 'Personalwirtschaft', url_rules: 'personalwirtschaft.de')
      source.save
      TwitterProcessor.new(source).process(count: 200)

      expect(source.news_items.count).to be > 0
      urls = source.news_items.map(&:url)
      expect(urls).to include "https://www.personalwirtschaft.de/arbeitsrecht/artikel/remote-work-im-arbeitsrecht.html"
      expect(source.news_items.first.teaser).to be_present
      expect(source.news_items.first.full_text).to be_present
    end
  end

  specify 'karrierespiegel -> recursive follow' do
    VCR.use_cassette 'karrierespiegel', record: :new_episodes do
      Setting.set('twitter_access_token', Rails.application.secrets.twitter_access_token)
      Setting.set('twitter_access_secret', Rails.application.secrets.twitter_access_secret)
      source = TwitterSource.new(url: 'KarriereSPIEGEL', name: 'KarriereSPIEGEL', url_rules: "spon.de\nspiegel.de/karriere")
      source.save
      TwitterProcessor.new(source).process(count: 20)

      expect(source.news_items.count).to be > 0
      urls = source.news_items.map(&:url)
      expect(urls).to include "https://www.spiegel.de/karriere/deutschland-immer-weniger-berufstaetige-wollen-fuehrungskraft-werden-a-1295517.html"
      expect(source.news_items.first.teaser).to be_present
      expect(source.news_items.first.full_text).to be_present
    end
  end

  specify 'Handelsblatt - paywall' do
    Rails.application.secrets.twitter_consumer_key = "lrcdzswhEHYM4CgnutP9eRWtI"
    Rails.application.secrets.twitter_consumer_secret = "u59zEwzLnKQ68a7RMD73QVZEcmNW2TpH1hZxrBNQLrN3BgDamY"
    VCR.use_cassette 'paywall/handelsblatt_twitter', record: :new_episodes do
      Setting.set('twitter_access_token', Rails.application.secrets.twitter_access_token)
      Setting.set('twitter_access_secret', Rails.application.secrets.twitter_access_secret)
      source = TwitterSource.new(url: 'handelsblatt', name: 'handelsblatt')
      source.save
      TwitterProcessor.new(source).process(count: 5)

      expect(source.news_items.count).to be > 0
      expect(source.news_items.where(paywall: true).count).to be > 0
    end
  end
end
