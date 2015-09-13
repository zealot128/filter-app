class StaticPagesController < ApplicationController
  before_action :skip_set_cookies_header
  def welcome
    @news_items = NewsItem.home_page.limit(36)
  end

  def about
  end

  def sources
  end
end
