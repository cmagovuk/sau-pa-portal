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
    session[:src_hint] = params[:src]
  end

  def remove
    @user = User.find(params[:id])
    session[:src_hint] = params[:src]
    @requests_created = Request.filter_by_user(@user.id)
      .group(:status).count
    @requests_submitted = Request.submitted_by(@user.id)
      .group(:status).count
  end

  def confirm_state
    user = User.find(params[:id])
    user.update!(disabled: user.disabled == "x" ? nil : "x")
    user.audit_logs.create!(AuditLog.log(auth_user, :user_status_change, email: user.email, status: user.disabled == "x" ? "deactivated" : "re-activated"))
    redirect_to_source user.public_authority_id
  end

  def confirm_remove
    user = User.find(params[:id])

    result = user_service.remove_user(user.oid, user.role)
    if result.present?
      if user.public_authority_id.present?
        user.public_authority.audit_logs.create!(AuditLog.log(auth_user, :user_removed, email: user.email))
      end
      user_pa_id = user.public_authority_id
      user.destroy!
      redirect_to_source user_pa_id
    else
      render "/errors/internal_server_error", status: :internal_server_error
    end
  end

  def edit
    user = User.find(params[:id])
    session[:users_params] = user
    session[:src_hint] = params[:src]
    redirect_to edit_user_step_path(:input)
  end

private

  def redirect_to_source(pa_id)
    src = session[:src_hint]
    session[:src_hint] = nil
    if src.present? && src == "pa"
      redirect_to public_authority_path(pa_id)
    else
      redirect_to users_path
    end
  end

  def user_service
    @user_service ||= UserService.new
  end
end
