class PaUserStepsController < SuperUserController
  before_action :load_user_params

  def edit
    render step
  end

  def update
    if pa_user_valid?
      if next_step
        redirect_to pa_user_step_path(next_step)
      elsif user.id.present?
        user_to_update = User.find(user.id)
        user_to_update.update!(user_name: user.user_name, phone: user.phone)
        user_to_update.audit_logs.create!(AuditLog.log(auth_user, :updated_user, email: user.email, role: I18n.t(user.role, scope: "helpers.label.user.role_options"), pa_name: user.public_authority.pa_name))
        redirect_to pa_users_path
      else
        result = user_service.invitation_result(user)
        if result.present?
          user.save!
          user.update!(oid: result.to_s)
          user.audit_logs.create!(AuditLog.log(auth_user, :created_user, email: user.email, role: I18n.t(user.role, scope: "helpers.label.user.role_options"), pa_name: user.public_authority.pa_name))
          user_service.pa_user_result(user.email, auth_user.name, auth_user.email, user.public_authority.pa_name)
          # send notification to client
          GovukNotifyService.send_user_invite_email(user)
          session[:user_step] = session[:users_params] = nil
          redirect_to pa_users_path
        else
          render "/errors/internal_server_error", status: :internal_server_error
        end
      end
    else
      render step
    end
  end

private

  STEPS = %w[input confirm].freeze

  def step
    @step ||= params[:id].to_s.downcase
  end

  def load_user_params
    session[:users_params] ||= {}
    session[:users_params].deep_merge!(user_params) if params[:user]
    user
  end

  def user
    @user ||= User.new(session[:users_params])
  end

  def pa_user_valid?
    return false unless user.valid?
    return true if user.id.present?

    user_domain = auth_user.email.split("@").last.downcase
    input_domain = user.email.split("@").last.downcase
    return true if user_domain == input_domain

    user.errors.add(:email, I18n.t("errors.attributes.email.domain", domain: user_domain))
    false
  end

  def next_step
    current_step_index = STEPS.index(step)
    STEPS[current_step_index + 1]
  end

  def user_params
    params.require(:user).permit(:user_name, :email, :public_authority_id, :role, :phone)
  end

  def user_service
    @user_service ||= UserService.new
  end
end
