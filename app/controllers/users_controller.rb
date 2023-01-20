class UsersController < AdminController
  def index
    @users = if params[:show_all] == "x"
               User.order(disabled: :desc, user_name: :asc)
             else
               User.active_users.order(:user_name)
             end
  end

  def new
    session[:users_params] = {}
    redirect_to edit_user_step_path(:input)
  end

  def change_state
    @user = User.find(params[:id])
  end

  def confirm_state
    user = User.find(params[:id])
    user.update!(disabled: user.disabled == "x" ? nil : "x")
    user.audit_logs.create!(AuditLog.log(auth_user, :user_status_change, email: user.email, status: user.disabled == "x" ? "deactivated" : "re-activated"))
    redirect_to users_path
  end

  def edit
    user = User.find(params[:id])
    session[:users_params] = user
    redirect_to edit_user_step_path(:input)
  end
end
