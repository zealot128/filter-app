require 'spec_helper'

describe StaticPagesController do
  describe "GET 'welcome'" do
    it "returns http success" do
      get :categories
      expect(response).to be_success
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get :about
      expect(response).to be_success
    end
  end
end
