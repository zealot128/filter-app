require 'spec_helper'

describe StaticPagesController do
  describe "GET 'welcome'" do
    it "returns http success" do
      get :categories
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get :about
      response.should be_success
    end
  end
end
