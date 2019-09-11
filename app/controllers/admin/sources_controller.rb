class Admin::SourcesController < AdminController
  load_and_authorize_resource

  def dashboard
  end

  def index
    @grid = SourcesGrid.new(grid_params) do |scope|
      scope.page(params[:page])
    end
  end

  def select
  end

  def autofetch
    url = params[:url]
    feed = FeedProcessor.new.parse_feed(url)
    ni = NewsItem.new(source: Source.new(full_text_selector: params[:full_text_selector]))
    selector = params[:full_text_selector]
    if feed.entries.first
      ni.url = feed.entries.first.url
      ft = NewsItem::FullTextFetcher.new(ni, unknown_selector: true)
      ft.run
      if params[:full_text_selector].blank? and ni.full_text
        selector = Processor::RULES.find { |i| ft.page.at(i) }
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
    else
      @source_types = Source::SOURCE_TYPES
      render 'select'
    end
  end

  def create
    type = params[:source].delete :type
    @source = type.constantize.new(params[:source].permit!)
    if @source.save
      Source::FetchWorker.perform_async(@source.id)

      redirect_to [:admin, :sources], notice: 'Done'
    else
      render :new
    end
  end

  def edit
    @source = Source.find(params[:id])
  end

  def update
    @source = Source.find(params[:id])
    if @source.update(params[:source].permit!)
      Source::FetchWorker.perform_async(@source.id)
      redirect_to [:admin, :sources], notice: 'Done'
    else
      render :edit
    end
  end

  def refresh
    @source = Source.find(params[:id])
    if params[:type] == 'source'
      Source::FetchWorker.perform_async(@source.id)
    end
    if params[:type] == 'news_items'
      @source.news_items.order('published_at desc').limit(10).each do |ni|
        NewsItem::RefreshLikesWorker.perform_async(ni.id)
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
