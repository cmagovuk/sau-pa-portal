class RequestsController < ApplicationController
  def show
    load_request(params[:id])
    return if performed?

    respond_to do |format|
      format.html { render :show }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=beis_td_import.xlsx"
      end
    end
  end

  def view
    load_request(params[:id])
  end

  def submitted
    load_request(session[:issue_id])
  end

  def confirm_delete
    load_request(params[:id])
  end

  def destroy
    load_request(params[:id])
    return if performed?

    @request.destroy!

    redirect_to requests_path
  end

  def new
    @request_type_form = RequestTypeForm.new
  end

  def index
    redirect_to ga_dashboard_path and return if auth_user.is_pa_ga_user?

    @requests = Request.pa_requests(auth_user.pa_id)
       .select(:id, :reference_number, :beneficiary, :scheme_name, :sectors, :status, :updated_at, :internal_state)
       .order(updated_at: :desc)

    @requests = @requests.filter_by_user(auth_user.user_id) if auth_user.is_pa_std_user?

    @requests = @requests.filter_by_status(params[:status]) if params[:status].present? && Request::STATUS.include?(params[:status])

    if params[:act].present? && Request::ACTIONS.include?(params[:act])
      case params[:act]
      when "Continue" then @requests = @requests.filter_by_status("Draft")
      when "Info required" then @requests = @requests.filter_by_internal_state("info-required").filter_by_status("Accepted")
      when "View" then @requests = @requests.filter_by_status(%w[Accepted Submitted Declined Rejected Withdrawn])
      when "View report" then @requests = @requests.filter_by_status("Completed")
      end
    end

    respond_to do |format|
      format.html { render :index }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=dashboard.xlsx"
      end
    end
  end

  def ga_dashboard
    redirect_to dashboard_path and return unless auth_user.is_pa_ga_user?

    @authorities = auth_user.sub_authorities.map { |a| [a.pa_name, a.id] }
    @requests = Request.pa_ga_requests(@authorities.map { |a| a[1] })
       .select(:id, :reference_number, :pa_name, :beneficiary, :scheme_name, :sectors, :status, :updated_at, :internal_state)
       .order(updated_at: :desc)

    @requests = @requests.filter_by_pa(params[:pa_id]) if params[:pa_id].present?

    @requests = @requests.filter_by_status(params[:status]) if params[:status].present? && Request::STATUS.include?(params[:status])

    if params[:act].present? && Request::ACTIONS.include?(params[:act])
      case params[:act]
      when "Info required" then @requests = @requests.filter_by_internal_state("info-required").filter_by_status("Accepted")
      when "View" then @requests = @requests.filter_by_status(%w[Accepted Submitted Declined Rejected Withdrawn])
      when "View report" then @requests = @requests.filter_by_status("Completed")
      end
    end

    respond_to do |format|
      format.html { render :ga_dashboard }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=dashboard.xlsx"
      end
    end
  end

  def reload
    session[:issue_id] = params[:id]
    load_request(params[:id])
    return if performed?

    step = "review"
    step = "referral_type" if @request.referral_type.blank?
    step = "call_in_type" if @request.referral_type == "call" && @request.call_in_type.blank?
    redirect_to edit_request_step_path(step)
  end

  def create
    @request_type_form = RequestTypeForm.new(params.require(:request).permit(:scheme_subsidy))
    if @request_type_form.save(auth_user)
      session[:issue_id] = @request_type_form.request.id
      redirect_to edit_request_step_path(wf.first_step)
    else
      render "new"
    end
  end

  def load_request(id)
    @request = Request.find(id)
    render template: "errors/unauthorised", status: :unauthorized unless auth_user.can_access_request?(@request)
  rescue StandardError
    render template: "/errors/not_found", status: :not_found
  end

private

  def wf
    @wf ||= Requests::StepWorkflow.new(request)
  end
end
