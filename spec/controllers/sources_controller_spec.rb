describe SourcesController do
  render_views

  specify '#index' do
    _ni = Fabricate(:news_item)
    get :index
    expect(response).to be_successful
  end

  specify '#show' do
    ni = Fabricate(:news_item)
    get :show, params: { id: ni.source_id }
    expect(response).to be_successful
  end

  specify '#search' do
    ni = Fabricate(:news_item)
    get :search, params: { id: ni.source_id, q: ni.title }
    # TODO: doesnt work in test cause of trigger/stored proc
    expect(response).to be_successful
  end
end
