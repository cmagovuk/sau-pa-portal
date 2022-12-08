class AccountsController < ApplicationController
  def show
    @user = User.find(auth_user.user_id)
    session[:users_params] = nil
  end

  def edit
    session[:users_params] = user
  end

  def update
    session[:users_params].deep_merge!(user_params) if params[:user]
    if user.valid?
      redirect_to confirm_account_path
    else
      render :edit
    end
  end

  def confirm
    session[:users_params] = user
  end

  def submit
    if user.valid?
      update_user = User.find(auth_user.user_id)
      update_user.update!(user_name: user.user_name, phone: user.phone)
      session[:users_params] = nil
      redirect_to requests_path
    else
      render :edit
    end
  end

  def user
    @user ||= if session[:users_params].present?
                User.new(session[:users_params])
              else
                User.find(auth_user.user_id)
              end
  end

private

  def user_params
    params.require(:user).permit(:user_name, :phone)
  end
end
