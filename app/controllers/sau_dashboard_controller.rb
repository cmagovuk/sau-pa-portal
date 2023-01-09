class SauDashboardController < SauController
  def index
    @authorities = PublicAuthority.order(:pa_name).map { |a| [a.pa_name, a.id] }
    @requests = Request.sau_requests
       .select(:id, :reference_number, :beneficiary, :scheme_name, :referral_type, :call_in_type, :status, :updated_at, :internal_state, :pa_name)
       .order(updated_at: :desc)

    @requests = @requests.filter_by_status(params[:status]) if params[:status].present? && Request::STATUS.include?(params[:status])
    @requests = @requests.filter_by_pa(params[:pa_id]) if params[:pa_id].present?

    # if params[:act].present? && Request::ACTIONS.include?(params[:act])
    #   case params[:act]
    #   when "Continue" then @requests = @requests.filter_by_status("Draft")
    #   when "Info required" then @requests = @requests.filter_by_internal_state("info-required").filter_by_status("Accepted")
    #   when "View" then @requests = @requests.filter_by_status(%w[Accepted Submitted])
    #   when "View report" then @requests = @requests.filter_by_status("Completed")
    #   end
    # end

    respond_to do |format|
      format.html { render :index }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=dashboard.xlsx"
      end
    end
  end
end
