class Admin::UsersController < ApplicationController
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
    if @user.update(permitted_params)
      flash[:notice] = 'User was successfully updated.'
      redirect_to '/admin/users'
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
end
