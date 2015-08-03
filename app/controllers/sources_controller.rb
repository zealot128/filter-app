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

    @news_items = @source.news_items.current.order('value desc')
    if @news_items.count < 50
      other = @source.news_items.
        visible.
        order('absolute_score desc').
        limit(50 - @news_items.count)
      if @news_items.any?
        other = other.where('news_items.id not in (?)', @news_items.map(&:id).presence || [-1])
      end
      @news_items += other
    end
  end
end
