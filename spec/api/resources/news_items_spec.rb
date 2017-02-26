require "spec_helper"
describe Resources::NewsItems, type: :request do

  specify 'filter' do
    Fabricate(:news_item, value: 1)

    get '/api/v1/news_items.json'
    expect(json.news_items.length).to be == 1
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
