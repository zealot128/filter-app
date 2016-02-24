class Admin::SettingsController < AdminController
  def index
    @settings = Setting.all
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update(params[:setting].permit!)
      Setting.clear
      redirect_to [:admin, :settings], notice: 'Done!'
    else
      render :edit
    end
  end
end
