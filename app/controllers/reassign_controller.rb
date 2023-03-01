class ReassignController < SuperUserController
  def edit
    @set_reassign_form = ReassignForm.new(param: params[:id])
    @set_reassign_form.reassign_to = session[:reassign_to]
    @request = Request.find(params[:id])
    @users = other_pa_users(@request)
  end

  def confirm
    if session[:reassign_to].present?
      @set_reassign_form = ReassignForm.new(param: params[:id])
      @set_reassign_form.reassign_to = session[:reassign_to]
      @request = Request.find(params[:id])
      @user = User.find(@set_reassign_form.reassign_to)
    else
      redirect_to edit_reassign_path
    end
  end

  def update
    @set_reassign_form = ReassignForm.new(set_reassign_params.merge(param: params[:id]))
    if @set_reassign_form.valid?
      session[:reassign_to] = @set_reassign_form.reassign_to
      redirect_to confirm_reassign_path
    else
      @request = Request.find(params[:id])
      @users = other_pa_users(@request)
      render :edit
    end
  end

  def submit
    if session[:reassign_to].present?
      @request = Request.find(params[:id])
      @users = other_pa_users(@request).select { |u| u[1] == session[:reassign_to] }
      if @users.one?
        original_owner = "#{@request.user.user_name} <#{@request.user.email}>"
        @request.update!(user_id: session[:reassign_to], submitted_by_id: session[:reassign_to])
        @request.audit_logs.create!(AuditLog.log(auth_user, :owner_change, from: original_owner, to: @users[0][0]))
      end
    end
    session[:reassign_to] = nil
    redirect_to request_path
  end

private

  def other_pa_users(request)
    request.public_authority.users.active_users.order(:user_name)
      .reject { |a| a.id == request.user_id }
      .map { |a| ["#{a.user_name} <#{a.email}>", a.id] }
  end

  def set_reassign_params
    params.require(:reassign).permit(:reassign_to)
  end
end
