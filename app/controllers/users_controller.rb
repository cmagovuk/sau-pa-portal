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

  def remove
    @user = User.find(params[:id])
    @requests_created = Request.filter_by_user(@user.id)
      .group(:status).count
    @requests_submitted = Request.submitted_by(@user.id)
      .group(:status).count
  end

  def confirm_state
    user = User.find(params[:id])
    user.update!(disabled: user.disabled == "x" ? nil : "x")
    user.audit_logs.create!(AuditLog.log(auth_user, :user_status_change, email: user.email, status: user.disabled == "x" ? "deactivated" : "re-activated"))
    redirect_to users_path
  end

  def confirm_remove
    user = User.find(params[:id])

    result = user_service.remove_user(user.oid, user.role)
    if result.present?
      if user.public_authority_id.present?
        user.public_authority.audit_logs.create!(AuditLog.log(auth_user, :user_removed, email: user.email))
      end
      user.destroy!
      redirect_to users_path
    else
      render "/errors/internal_server_error", status: :internal_server_error
    end
  end

  def edit
    user = User.find(params[:id])
    session[:users_params] = user
    redirect_to edit_user_step_path(:input)
  end

private

  def user_service
    @user_service ||= UserService.new
  end
end
