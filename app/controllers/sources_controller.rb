class SourcesController < ApplicationController
  before_action :stop_bad_crawler!, only: :search
  before_action :allow_iframe_requests

  rescue_from ArgumentError do
    head(:no_content)
  end

  def index
    @count_feed = 0
    @count_yt = 0
    @count_podcasts = 0
    @count_socialmedia = 0
    @sources_feed = Source.where("type = 'FeedSource'")
    @sources_feed.each do |source|
      @count_feed = @count_feed + source.news_items.count
    end
    @sources_yt = Source.where("type = 'Youtube'")
    @sources_yt.each do |source|
      @count_yt = @count_yt + source.news_items.count
    end
    @sources_podcasts = Source.where("type = 'Podcasts'")
    @sources_podcasts.each do |source|
      @count_podcasts = @count_podcasts + source.news_items.count
    end
    @sources_socialmedia = Source.where("type = 'SocialMedia'")
    @sources_socialmedia.each do |source|
      @count_socialmedia = @count_socialmedia + source.news_items.count
    end
    if params[:source_type] == "feed"
      @sources = @sources_feed
    elsif params[:source_type] == "yt"
      @sources = @sources_yt
    elsif params[:source_type] == "podcasts"
      @sources = @sources_podcasts
    elsif params[:source_type] == "socialmedia"
      @sources = @sources_socialmedia
    else
      @sources = @sources_feed
    end
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

  def search
    @source = Source.find(params[:id])
    minscore = 0.5
    found_news_items = if params[:q].present?
                         @source.news_items.
                           where('published_at > ?', 2.years.ago).
                           includes(:source, :categories).
                           search_full_text(params[:q]).
                           with_pg_search_rank.where('rank > ?', minscore)
                       else
                         @source.news_items.
                           includes(:source, :categories)
                       end
    @news_items = found_news_items.paginate(page: params[:page], per_page: 40)
    # @chart = Charts::SourceTimeChart.new(@source, news_items: @found_news_items)
    @title = "#{params[:q]} | #{@source.name}"
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
