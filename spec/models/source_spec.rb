describe Source do
  specify 'download thumb' do
    VCR.use_cassette 'persoblogger', record: :new_episodes do
      source = Source.new(url: 'https://persoblogger.wordpress.com/feed/', name: 'perso')
      source.save
      source.download_thumb
      expect(source.reload.logo).to be_present
      expect(File.exist?(source.reload.logo.path(:small))).to eq(true)
    end
  end
  specify 'shouldnt download anything if logo not available' do
    VCR.use_cassette 'broken_thumb', record: :new_episodes do
      source = Source.new(url: 'http://www.arbeit-und-arbeitsrecht.de/aktuelle_meldungen', name: 'feed')
      source.save
      source.download_thumb
      expect(source.reload.logo).not_to be_present
    end
  end

  specify 'relative urls are converted' do
    VCR.use_cassette 'relative_url', record: :new_episodes do
      source = FeedSource.new(url: "https://parisax.de/index.php?id=131&type=7531", name: 'pixmax')
      source.save
      source.refresh
      expect(source.news_items.count).to be > 0
      expect(source.news_items.first.url).to start_with 'http'
    end
  end
	specify 'Fahrradio Podcast "image"' do
    VCR.use_cassette 'podcast' do
      source = PodcastSource.new(
        url: "http://fahrrad.io/feed/",
        name: "Fahrradio")
      source.save
      source.refresh
    end
  end
end
