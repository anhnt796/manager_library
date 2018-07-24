class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update)
  before_action :find_user, only: %i(show edit update)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @users = User.all_user.paginate page: params[:page],
      per_page: Settings.OBJECT_PER_PAGE
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:info] = t ".message"
      redirect_to @user
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t ".updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t ".destroyed"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t ".notfound"
    redirect_to root_url
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "users.logged_in_user.pleaselog"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless current_user.current_user? @user
  end
end
