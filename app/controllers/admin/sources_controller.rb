class Admin::SourcesController < AdminController
  load_and_authorize_resource

  def dashboard
  end

  def index
    @grid = SourcesGrid.new(grid_params) do |scope|
      scope.page(params[:page])
    end
    @title = "Quellen"
  end

  def download_image
    @source = Source.find(params[:id])
    url = params[:url]
    if url
      require 'download_url'
      @source.update! logo: download_url(url), image_candidates: nil
    else
      @source.update! image_candidates: nil
    end
  end

  def score_chart
    @source = Source.find(params[:id])
    render json: {
      chart: Charts::SourceScoreChart.new(@source, max: 3.months.ago).to_highcharts
    }
  end

  def select
  end

  def autofetch
    url = params[:url]
    feed = FeedProcessor.new.parse_feed(url)
    ni = NewsItem.new(source: Source.new(full_text_selector: params[:full_text_selector]))
    selector = params[:full_text_selector]
    if feed.entries.first
      ni.url = feed.entries.first.url.strip
      ft = NewsItem::FullTextFetcher.new(ni, unknown_selector: true)
      ft.run
      if params[:full_text_selector].blank? and ni.full_text
        selector = BaseProcessor::RULES.find { |i| ft.page.at(i) }
      end
    end

    render json: {
      title: feed.title,
      found_selector: selector,
      first_news: {
        title: ni.title || feed.entries.first&.title,
        url: ni.url,
        full_text: ni.full_text,
      }
    }
  end

  def new
    if params[:source_type]
      @source = params[:source_type].constantize.new
      @source.value = 1
      @source.multiplicator = 1
      @source.language = 'german'
    else
      @source_types = Source::SOURCE_TYPES
      render 'select'
    end
  end

  def create
    type = params[:source].delete :type
    @source = type.constantize.new(params[:source].permit!)
    if @source.save
      Source::FetchJob.perform_later(@source.id)
      if @source.logo.blank?
        Source::FindLogosJob.set(wait: 1.minute).perform_later(@source.id)
      end

      redirect_to [:admin, :sources], notice: 'Quelle angelegt'
    else
      render :new
    end
  end

  def edit
    @source = Source.find(params[:id])
    @title = "EDIT #{@source.name}"
  end

  def update
    @source = Source.find(params[:id])
    if @source.update(params[:source].permit!)
      Source::FetchJob.perform_later(@source.id)
      if @source.previous_changes.slice('value', 'multiplicator').present?
        Source::RescoreAllJob.perform_later(@source.id)
      end
      redirect_to [:admin, :sources], notice: 'Done'
    else
      render :edit
    end
  end

  def refresh
    @source = Source.find(params[:id])
    if params[:type] == 'source'
      Source::FetchJob.perform_later(@source.id)
    end
    if params[:type] == 'news_items'
      @source.news_items.order('published_at desc').limit(10).each do |ni|
        NewsItem::RefreshLikesJob.perform_later(ni.id)
      end
    end
  end

  def destroy
    @source = Source.find(params[:id])
    @source.destroy
    redirect_to [:admin, :sources], notice: 'Done'
  end

  protected

  def grid_params
    params.fetch(:sources_grid, {}).permit!
  end

  def resource_params
    params[:source].permit!
  end
end
