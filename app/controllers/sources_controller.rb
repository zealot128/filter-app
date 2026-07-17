class SourcesController < ApplicationController
  before_action :allow_iframe_requests

  rescue_from ArgumentError do
    head(:no_content)
  end

  def index
    @sources = Source.order(Arel.sql('lower(name)'))
  end

  def show
    @source = Source.find(params[:id])
    found_news_items = @source.news_items.show_page
    found_news_items.reorder!
    @categories = found_news_items.
      joins(:categories).
      group('categories.name').order('count_all desc').limit(5).count
    @count = found_news_items.count
    @avg = 10
    @news_items = found_news_items.limit(30)
    @chart = Charts::SourceTimeChart.new(@source)
    @title = @source.name

    @page_description = "#{@source.news_items.count} News der Quelle #{@source.name}"
    @page_keywords = @categories.map(&:first).join(',')
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
