describe Resources::NewsItems, type: :request do
  describe '/api/v1/news_items' do
    specify 'filter' do
      Fabricate(:news_item, absolute_score: 1)

      get '/api/v1/news_items.json'
      expect(json.news_items.length).to be == 1
    end

    specify 'Blacklisting source' do
      n1  = Fabricate(:news_item, absolute_score: 1)
      n2  = Fabricate(:news_item, absolute_score: 1)
      expect(n1.source).to_not eq n2.source

      get '/api/v1/news_items.json', params: { blacklisted: n2.source.id }
      expect(json.news_items.length).to be == 1
    end

    specify 'Preferring source' do
      n1  = Fabricate(:news_item, absolute_score: 10)
      n2  = Fabricate(:news_item, absolute_score: 11)
      expect(n1.source).to_not eq n2.source

      get '/api/v1/news_items.json', params: { preferred: n1.source_id }
      expect(json.news_items.length).to be == 2
      expect(json.news_items.first.id).to be == n1.id
    end

    specify 'Category filter' do
      c1 = Fabricate(:category)
      c2 = Fabricate(:category, name: "Bildung", keywords: "weiterbildung")
      n1 = Fabricate(:news_item, absolute_score: 10)
      n1.categories << c1
      n1.categories << c2
      n2 = Fabricate(:news_item, absolute_score: 11)
      n2.categories << c1

      get '/api/v1/news_items.json', params: { categories: c2.id }
      expect(json.news_items.length).to be == 1
    end

    specify 'ranking by freshness' do
      n1 = Fabricate(:news_item, absolute_score: 11, published_at: 5.days.ago)
      n2 = Fabricate(:news_item, absolute_score: 10, published_at: Time.zone.now)

      get '/api/v1/news_items.json'
      expect(json.news_items.map(&:id)).to be == [n2.id, n1.id]
    end

    specify 'order by top score per day (Smoke test)' do
      Fabricate(:news_item, absolute_score: 10, value: 10, published_at: 1.day.ago)

      get '/api/v1/news_items.json', params: { order: 'best' }
      expect(json.news_items.length).to be == 1
    end

    specify 'teaser enabled' do
      ni = Fabricate(:news_item, absolute_score: 10, value: 10, published_at: 1.day.ago)
      ni.source.update lsr_active: true

      get '/api/v1/news_items.json', params: { teaser_enabled: '1' }
      expect(json.news_items.length).to be == 0

      get '/api/v1/news_items.json', params: { teaser_enabled: nil }
      expect(json.news_items.length).to be == 1
    end

    specify 'image' do
      _without_image = Fabricate(:news_item, absolute_score: 10, value: 10, published_at: 1.day.ago)
      with_image = Fabricate(:news_item, absolute_score: 10, value: 10, published_at: 1.day.ago, image: File.open('app/assets/images/hrfilter/hrfilter-logo.png'))

      get '/api/v1/news_items.json', params: { image_exists: nil }
      expect(json.news_items.length).to be == 2

      get '/api/v1/news_items.json', params: { image_exists: '1' }
      expect(json.news_items.length).to be == 1
      expect(json.news_items.first['id']).to be == with_image.id
    end
  end

  describe '/api/v1/sources' do
    specify 'get /:id' do
      s = Fabricate(:source)

      get "/api/v1/sources/#{s.id}.json"
      expect(json.source.name).to be == s.name
    end
  end

  def json
    j = JSON.load(response.body)
    if j.is_a?(Hash)
      Hashie::Mash.new(j)
    else
      j
    end
  end
end
