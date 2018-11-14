class Admin::SourcesController < AdminController
  def dashboard
  end

  def index
    @grid = SourcesGrid.new(grid_params) do |scope|
      scope.page(params[:page])
    end
  end

  def select
  end

  def new
    if params[:source_type]
      @source = params[:source_type].constantize.new
    else
      @source_types = Source::SOURCE_TYPES
      render 'select'
    end
  end

  def create
    type = params[:source].delete :type
    @source = type.constantize.new(params[:source].permit!)
    if @source.save
      begin
        @source.refresh
        @source.news_items.current.map(&:rescore!)
      rescue StandardError
      end
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
      @source.refresh
      @source.download_thumb if @source.logo.blank?
      @source.news_items.current.map(&:rescore!)
      redirect_to [:admin, :sources], notice: 'Done'
    else
      render :edit
    end
  end

  def refresh
    @source = Source.find(params[:id])
    begin
      if params[:type] == 'source'
        @source.wrapped_refresh!
      end
      if params[:type] == 'news_items'
        @source.news_items.order('published_at desc').limit(10).each(&:refresh)
      end
    rescue Exception => e
      @error = e.inspect
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
end
