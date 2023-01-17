class UserStepsController < AdminController
  before_action :load_user_params, :load_authorities

  def edit
    render step
  end

  def update
    if user.valid?
      if next_step
        redirect_to user_step_path(next_step)
      elsif user.id.present?
        user_to_update = User.find(user.id)
        user_to_update.update!(user_name: user.user_name, phone: user.phone, role: user.role, public_authority_id: user.public_authority_id, disabled: user.disabled)
        redirect_to users_path
      else
        result = user_service.invitation_result(user)
        if result.present?
          user.save!
          user.update!(oid: result.to_s)
          # send notification to client
          GovukNotifyService.send_user_invite_email(user)
          session[:user_step] = session[:users_params] = nil
          redirect_to users_path
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

  def load_authorities
    authorities
  end

  def authorities
    @authorities ||= PublicAuthority.order(:pa_name).map { |a| [a.pa_name, a.id] }
  end

  def next_step
    current_step_index = STEPS.index(step)
    STEPS[current_step_index + 1]
  end

  def user_params
    params.require(:user).permit(:user_name, :email, :public_authority_id, :role, :phone, :disabled)
  end

  def user_service
    @user_service ||= UserService.new
  end
end
