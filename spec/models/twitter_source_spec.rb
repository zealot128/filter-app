RSpec.describe TwitterSource do
  specify 'twitter personalwirtschaft' do
    # NOTE:
    # To rerun without cassette set valid twitter creds and anonymize afterwards in spec/fixtures/vcr_cassettes/personalwirtschaft.yml
    # Rails.application.secrets.twitter_consumer_key = "xxxx"
    # Rails.application.secrets.twitter_consumer_secret = "xxxx"
    # Setting.set('twitter_access_token', "xxxx")
    # Setting.set('twitter_access_secret', "xxxx")

    VCR.use_cassette 'personalwirtschaft', record: :new_episodes do
      source = TwitterSource.new(url: 'personaler_de', name: 'Personalwirtschaft')
      source.save
      source.refresh

      expect(source.news_items.count).to be > 0
      urls = source.news_items.map(&:url)
      expect(urls).to include "https://www.personalwirtschaft.de/fuehrung/artikel/deutsche-arbeitnehmer-bemaengeln-fehlende-unterstuetzung-bei-digitaler-weiterbildung.html"
    end
  end
end
