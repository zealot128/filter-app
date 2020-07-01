RSpec.describe BaseProcessor, type: :model do
  specify 'Reddit' do
    VCR.use_cassette 'reddit-1' do
      rs = RedditSource.create!(name: 'bicycling')
      rs.refresh
      expect(rs.news_items.count).to be > 5
    end
  end
end
