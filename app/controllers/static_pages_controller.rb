class StaticPagesController < ApplicationController
  def welcome
    @news_items = NewsItem.home_page.limit(48)
  end

  def about
  end

  def sources
  end
end
