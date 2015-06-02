class SourcesController < ApplicationController
  def index
    @sources = Source.order('lower(name)')
  end

  def show
    @source = Source.find(params[:id])
    @categories = @source.news_items.
      joins(:categories).
      group('categories.name').order('count_all desc').limit(5).count
    @count = @source.news_items.count
    @avg = @count / @source.age_in_weeks
  end
end
