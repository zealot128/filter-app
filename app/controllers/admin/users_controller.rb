class Admin::UsersController < AdminController
  authorize_resource
  before_action :find_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(permitted_params)
    @user.skip_password_validation = true
    if @user.save
      @user.send_reset_password_instructions
      flash[:notice] = 'User was successfully created.'
      redirect_to '/admin/users'
    else
      render :new
    end
  end

  def update
    should_sign_in = current_user == @user
    if @user.update(permitted_params)
      flash[:notice] = 'User was successfully updated.'
      bypass_sign_in(@user) if should_sign_in
      if current_user.admin?
        redirect_to '/admin/users'
      else
        redirect_to '/admin'
      end
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = 'User was successfully deleted.'
    redirect_to '/admin/users'
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def permitted_params
    if current_user.admin?
      params.require(:user).permit!
    else
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end

  def resource_params
    permitted_params
  end
end
