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

  def new
    @request_type_form = RequestTypeForm.new
  end

  def index
    @requests = Request.pa_requests(auth_user.pa_id)
       .select(:id, :reference_number, :beneficiary, :scheme_name, :sectors, :status, :updated_at, :internal_state)
       .order(updated_at: :desc)

    @requests = @requests.filter_by_status(params[:status]) if params[:status].present? && Request::STATUS.include?(params[:status])

    if params[:act].present? && Request::ACTIONS.include?(params[:act])
      case params[:act]
      when "Continue" then @requests = @requests.filter_by_status("Draft")
      when "Info required" then @requests = @requests.filter_by_internal_state("info-required").filter_by_status("Accepted")
      when "View" then @requests = @requests.filter_by_status(%w[Accepted Submitted])
      when "View report" then @requests = @requests.filter_by_status("Completed")
      end
    end

    #  @requests = @requests.filter_by_action(params[:act]) if params[:act].present? && Request::ACTIONS.include?(params[:act])

    respond_to do |format|
      format.html { render :index }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=dashboard.xlsx"
      end
    end
  end

  def reload
    session[:issue_id] = params[:id]
    load_request(params[:id])
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
