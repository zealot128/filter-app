class Admin::SettingsController < AdminController
  def index
    @settings = Setting.all
  end

  def new
    @setting = Setting.new
  end

  def create
    @setting = Setting.new(params[:setting].permit!)
    if @setting.save
      redirect_to [:admin, :settings], notice: 'Done!'
    else
      render :new
    end

  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update(params[:setting].permit!)
      redirect_to [:admin, :settings], notice: 'Done!'
    else
      render :edit
    end
  end
end
