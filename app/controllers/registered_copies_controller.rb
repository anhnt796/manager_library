class RegisteredCopiesController < ApplicationController
  before_action :find_book, only: %i(new)
  before_action :find_registered_copy, only: %i(destroy)
  before_action :has_card?, only: %i(index new)

  def index
    @registered_copies = current_user.card.registered_copies.page(params[:page])
  end

  def new
    @registered_copy = RegisteredCopy.new registered_date: Date.today,
      copy_id: @book.random_copies_available.try(:id),
      card_id: current_user.card_id
  end

  def create
    @registered_copy = RegisteredCopy.new registered_copy_params
    if set_borrowed
      if @registered_copy.save
        flash[:info] = t ".success"
        redirect_to root_url
      else
        render :new
      end
    else
      flash[:danger] = t ".status_fail"
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    if set_available
      @registered_copy.destroy
      flash[:success] = t ".book_returned"
      redirect_to root_url
    else
      flash[:danger] = t ".status_fail"
      redirect_back fallback_location: root_path
    end
  end

  private

  def registered_copy_params
    params.require(:registered_copy).permit :registered_date, :copy_id, :card_id
  end

  def find_book
    @book = Book.find_by id: params[:book_id]
    return if @book
    flash[:danger] = t ".not_exists"
    redirect_to root_url
  end

  def find_copy
    @copy = Copy.find_by id: params[:id]
    return if @copy
    flash[:danger] = t ".not_exists"
    redirect_to root_url
  end

  def set_available
    @copy = Copy.find_by id: @registered_copy.copy_id
    return if !@copy || @copy.available?
    @copy.set_status :available
  end

  def set_borrowed
    @copy = Copy.find_by id: @registered_copy.copy_id
    return if !@copy || @copy.borrowed?
    @copy.set_status :borrowed
  end

  def find_registered_copy
    @registered_copy = RegisteredCopy.find_by id: params[:id]
    return if @registered_copy
    flash[:danger] = t ".not_exists"
    redirect_to root_url
  end

  def has_card?
    return if current_user.card
    flash[:danger] = t ".no_card"
    redirect_to root_url
  end
end
