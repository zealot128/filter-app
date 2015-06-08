class StaticPagesController < ApplicationController
  def welcome
    @news_items = NewsItem.home_page.limit(36)
  end

  def about
  end

  def sources
  end
end
