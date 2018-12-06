RSpec.describe JobsController, type: :controller do
  render_views
  specify 'jobs index' do
    Setting.set('jobs_url', "https://login.empfehlungsbund.de/api/v2/jobs/search.json?q=personal%20hr&fair=false&min_score=1.2&portal_types=office&per=1")
    VCR.use_cassette('jobs_1') do
      get :index
    end
    expect(response).to be_successful
    expect(response.body).to include "Nichts gefunden?"
  end
end
