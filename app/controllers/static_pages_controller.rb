class StaticPagesController < ApplicationController
  def welcome
    @news_items = NewsItem.home_page
  end

  def about
  end

  def sources
  end
end
