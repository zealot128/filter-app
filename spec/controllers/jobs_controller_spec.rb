RSpec.describe JobsController, type: :controller do
  render_views
  before(:each) do
    Rails.cache.clear
  end

  specify 'jobs index' do
    Setting.set('jobs_url', "https://login.empfehlungsbund.de/api/v2/jobs/search.json?q=personal%20hr&fair=false&min_score=1.2&portal_types=office&per=1")
    VCR.use_cassette('jobs_1') do
      get :index
    end
    expect(response).to be_successful
    # expect(response.body).to include "Nichts gefunden?"
  end

  specify 'events index' do
    VCR.use_cassette('jobs/events') do
      get :events, format: 'json'
    end
    expect(response).to be_successful
    # expect(JSON.parse(response.body).count).to be > 0
  end

  specify 'leere events - serializer error?' do
    expect(AdLogic).to receive(:promoted_events).and_return([])

    get :events, format: 'json'
    expect(response).to be_successful
    expect(response.parsed_body.count).to be == 0
  end
end
