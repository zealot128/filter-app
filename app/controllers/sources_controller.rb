class SourcesController < ApplicationController
  def index
    @sources = Source.order('lower(name)')
  end

  def show
    @source = Source.find(params[:id])
    @categories = @source.news_items.
                  joins(:categories).
                  group('categories.name').order('count_all desc').limit(5).count
    @count = @source.news_items.show_page.count
    @avg = @count / @source.age_in_weeks

    @news_items = @source.news_items.show_page.limit(100)
  end
end
