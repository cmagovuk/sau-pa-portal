class UsersController < AdminController
  def index
    @users = User.order(:user_name)
  end

  def new
    session[:users_params] = {}
    redirect_to edit_user_step_path(:input)
  end

  def edit
    user = User.find(params[:id])
    session[:users_params] = user
    redirect_to edit_user_step_path(:input)
  end
end
