class UsersController < ApplicationController
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @search = User.search(params[:q])
    @users = @search.result.page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
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

  def register_card; end

  def require_card
    unless current_user.card_activated?
      current_user.create_card_token
      current_user.terms_of_service = params[:user][:terms_of_service]
      send_mail_card_activation current_user
    end
    redirect_to current_user
  end

  private

  def user_params
    params.require(:user).permit :name, :first_name, :last_name, :contact
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.friendly.find params[:id]
    return if @user
    flash[:warning] = t ".notfound"
    redirect_to root_url
  end

  def correct_user
    redirect_to root_url unless current_user.current_user? @user
  end

  def send_mail_card_activation user
    if user.save
      UserMailer.card_activation(user).deliver_now
      flash[:info] = t "users.require_card.check_mail"
    else
      flash[:warning] = t "user.errors.full_messages.join"
    end
  end
end
