class Admin::SourcesController < AdminController
  def index
    @sources = Source.order(:name)
  end

  def new
    @source = Source.new
  end

  def create
    type = params[:source].delete :type
    @source = type.constantize.new(params[:source].permit!)
    if @source.save
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
      @source.download_thumb
      redirect_to [:admin, :sources], notice: 'Done'
    else
      render :edit
    end
  end

  def destroy
    @source = Source.find(params[:id])
    @source.destroy
    redirect_to [:admin, :sources], notice: 'Done'
  end
end
