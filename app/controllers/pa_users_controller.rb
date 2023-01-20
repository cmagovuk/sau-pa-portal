class PaUsersController < SuperUserController
  def index
    @users = auth_user.public_authority.users.active_users.order(:user_name)
  end

  def new
    session[:users_params] = {}
    redirect_to edit_pa_user_step_path(:input)
  end

  def change_state
    @user = User.find(params[:id])
  end

  def confirm_state
    user = User.find(params[:id])
    user.update!(disabled: "x")
    user.audit_logs.create!(AuditLog.log(auth_user, :user_status_change, email: user.email, status: "deactivated"))
    redirect_to pa_users_path
  end

  def edit
    user = User.find(params[:id])
    session[:users_params] = user
    redirect_to edit_pa_user_step_path(:input)
  end
end
