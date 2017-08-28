require 'spec_helper'

describe ApiController do
  let(:news_item) {Fabricate.create(:news_item)}
  let(:body) {JSON.parse(response.body)}
  describe "Categories" do
    it "/:id returns a category with news_items_count" do
      get :category, id: news_item.categories.first.id
      expect(response).to be_success
    end

  end
end
