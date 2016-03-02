require 'spec_helper'

describe Source do
  specify 'download thumb' do
    VCR.use_cassette 'persoblogger', record: :new_episodes do
      source = Source.new(url: 'https://persoblogger.wordpress.com/feed/', name: 'perso')
      source.save
      source.download_thumb
      expect(source.reload.logo).to be_present
      expect(File.exists?(source.reload.logo.path(:small))).to eq(true)
    end
  end
  specify 'shouldnt download anything if logo not available' do
    VCR.use_cassette 'broken_thumb', record: :new_episodes do
      source= Source.new(url: 'http://www.arbeit-und-arbeitsrecht.de/aktuelle_meldungen', name: 'feed')
      source.save
      source.download_thumb
      expect(source.reload.logo).not_to be_present
    end
  end
end
