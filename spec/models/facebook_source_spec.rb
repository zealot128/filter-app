require "spec_helper"
describe FacebookSource do
  specify 'Full test' do
    VCR.use_cassette 'source/facebook-personalw', record: :new_episodes do
      source = FacebookSource.new(
        url: "personalwirtschaft.de",
        name: "Personalwirtschaft.de",
        full_text_selector: ".cms-content"
      )
      source.save!
      source.refresh

      expect(source.news_items.count).to be > 1

      source.download_thumb
      expect(source.logo).to be_present
    end
  end

end
