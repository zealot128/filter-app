class StaticPagesController < ApplicationController
  def welcome
    @news_items = NewsItem.home_page.limit(30)
  end

  def about
  end

  def sources
  end
end
