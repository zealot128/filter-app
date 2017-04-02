require 'spec_helper'

describe DaysController do
  render_views

  specify '#index' do
    Fabricate(:news_item)
    get :index
    expect(response).to be_success
  end

  specify '#show' do
    ni = Fabricate(:news_item)
    get :show, year: ni.published_at.year, month: ni.published_at.month, day: ni.published_at.day
    expect(response).to be_success
    expect(assigns(:news).count).to be == 1
  end
end
