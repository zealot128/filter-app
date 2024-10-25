describe NewsItem do
  describe "Like-Fetcher" do
    let(:like_fetcher) { NewsItem::LikeFetcher.new("http://stefanwienert.net/blog/2013/02/08/faster-rails-tests-with-spring-faster-than-spork-und-easier-to-setup/") }

    specify 'All' do
      VCR.use_cassette 'like_fetcher/one', record: :new_episodes do
        ni = Fabricate(:news_item, url: 'http://www.itsax.de/news/portal/1807/aufgepasst-diese-5-stellenangebote-unserer-partner-muessen-sie-gesehen-haben')
        NewsItem::LikeFetcher.fetch_for_news_item(ni)
      end
    end
  end

  describe "Categorizer" do
    specify "Default assigns keywords" do
      c1 = Fabricate(:category, keywords: 'gehalt,bwl')
      c2 = Fabricate(:category, name: 'Bildung' ,keywords: 'foobar')

      ni = Fabricate.build(:news_item, title: 'Gehalt bla')
      ni.source.default_category = c2
      ni.categorize
      expect(ni.categories.sort_by { |i| i.id }).to eq([c1, c2])

      ni.source.default_category = nil
      ni.categorize
      expect(ni.categories).to eq([c1])
    end

    xspecify "Reihenfolge der Kategorien bleiben erhalten" do
      c1 = Fabricate(:category, name: 'Bewerbung', keywords: 'gehalt,bwl')
      c2 = Fabricate(:category, name: 'Recruiting', keywords: 'recruiting')
      c3 = Fabricate(:category, keywords: 'studium')

      ni = Fabricate(:news_item, title: 'studium studium  Gehalt Gehalt Gehalt Recruiting')
      ni.categorize
      expect(ni.reload.categories.map(&:keywords)).to eq([c1, c3, c2].map(&:keywords))
    end
  end
end
