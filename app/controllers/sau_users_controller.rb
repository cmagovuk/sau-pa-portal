class SauUsersController < AdminController
  def index
    @user_data = sau_user_service.get_users
  end

  def remove
    @user_data = sau_user_service.get_group_users(params[:group])
    @user_data.select! { |u| u["id"] == params[:id] }

    render template: "/errors/not_found", status: :not_found and return unless @user_data.count == 1
  end

  def destroy
    sau_user_service.remove_user(params[:group], params[:id])
    redirect_to "#{sau_users_path}##{t("sau_groups.#{params[:group]}").parameterize}"
  end

  def new
    @sau_user_form = SauUserForm.new(session[:sau_user])
    @sau_user_form.group = params[:group] if params[:group]
  end

  def create
    @sau_user_form = SauUserForm.new(sau_user_params)
    if @sau_user_form.valid?
      session[:sau_user] = sau_user_params
      redirect_to confirm_sau_users_path
    else
      render :new
    end
  end

  def confirm
    @sau_user_form = SauUserForm.new(session[:sau_user])
  end

  def submit
    @sau_user_form = SauUserForm.new(session[:sau_user])

    session[:sau_user] = nil
    sau_user_service.add_user(@sau_user_form.group, @sau_user_form.email_addr)
    redirect_to "#{sau_users_path}##{t("sau_groups.#{@sau_user_form.group}").parameterize}"
  end

private

  def sau_user_params
    params.require(:sau_user_form).permit(%w[group email_addr])
  end

  def sau_user_service
    @sau_user_service ||= SauUserService.new
  end
end
