class SourcesController < ApplicationController
  def index
    @sources = Source.order('lower(name)')
  end

  def show
    @source = Source.find(params[:id])
    found_news_items = @source.news_items.show_page
    found_news_items.reorder!
    @categories = found_news_items.
                  joins(:categories).
                  group('categories.name').order('count_all desc').limit(5).count
    @count = found_news_items.count
    @avg = @count / @source.age_in_weeks

    @news_items = found_news_items.limit(30)
    @chart = Charts::SourceTimeChart.new(@source)

    @title = @source.name
  end

  def search
    @source = Source.find(params[:id])
    minscore = 0.5
    if params[:q].present?
      found_news_items = @source.news_items.
        where('published_at > ?', 2.years.ago).
        includes(:source, :categories).
        search_full_text(params[:q]).
        with_pg_search_rank.where('rank > ?', minscore)
    else
      found_news_items = @source.news_items.
        includes(:source, :categories)
    end
    @news_items = found_news_items.paginate(page: params[:page], per_page: 40)
    # @chart = Charts::SourceTimeChart.new(@source, news_items: @found_news_items)
    #
    @title = "#{params[:q]} | #{@source.name}"
  end
end
