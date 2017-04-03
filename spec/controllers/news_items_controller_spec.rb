require 'spec_helper'

describe NewsItemsController do
  render_views

  specify 'show redirects to original url and increments counter' do
    ni = Fabricate(:news_item)
    get :show, id: ni.id
    expect(response.location).to be == ni.url
    expect(Impression.count).to be == 1
  end

  describe 'Old API: #homepage' do
    specify 'uncategorized + recent' do
      _ni = Fabricate(:news_item)
      get :homepage, order: :recent, category: -1
      expect(response).to be_success
    end
  end

  describe 'Old Homepage/now Search' do
    specify '#1' do
      _ni = Fabricate(:news_item, title: 'FILTER')
      get :index, q: 'FILTER'
      expect(response).to be_success
      # TODO: Doesn't work in Test - no trigger/stored procs
      expect(assigns(:news_items)).to be == []
    end
  end
end
