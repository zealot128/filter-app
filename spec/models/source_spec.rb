require 'spec_helper'

describe Source do
  specify 'download thumb' do
    VCR.use_cassette 'persoblogger', record: :new_episodes do
      source = Source.new(url: 'https://persoblogger.wordpress.com/feed/', name: 'perso')
      source.save
      source.download_thumb
      source.reload.logo.should be_present
    end
  end
end
