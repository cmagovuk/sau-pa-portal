class SauDashboardController < SauController
  def all
    @authorities = PublicAuthority.order(:pa_name).map { |a| [a.pa_name, a.id] }
    @requests = Request.sau_requests
       .select(:id, :reference_number, :beneficiary, :scheme_name, :referral_type, :call_in_type, :status, :updated_at, :internal_state, :pa_name)
       .order(updated_at: :desc)

    filter_requests

    respond_to do |format|
      format.html { render :all }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=dashboard.xlsx"
      end
    end
  end

  def full
    @requests = Request.sau_requests
    .select(:scheme_subsidy, :referral_type, :status, :reference_number, :direction_date, :pa_name, :created_at, :updated_at,
            :call_in_type, :subsidy_form, :budget, :tax_amt, :sectors, :purposes, :start_date, :end_date, :confirm_date,
            :beneficiary, :ben_id_type, :ben_id, :ben_size, :ben_good_svr, :location, :ee_assess_required, :par_on_td, :par_td_ref_no, :par_assessed,
            :previous_refno, :previous_status, :sau_call_in, :tax_low, :tax_high, :report_due_date, :submitted_date, :decision_date,
            :completed_date, :is_c2_relevant, :is_p3_relevant, :is_emergency, :subsidy_forms, :org_level_1, :org_level_2)
    .order(reference_number: :desc)
    respond_to do |format|
      format.html { render "/errors/not_found", status: :not_found }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=all_requests.xlsx"
      end
    end
  end

  def index
    @authorities = PublicAuthority.order(:pa_name).map { |a| [a.pa_name, a.id] }
    @requests = Request.open_sau_requests
       .select(:id, :reference_number, :beneficiary, :scheme_name, :referral_type, :call_in_type, :status, :submitted_date, :report_due_date, :decision_date, :internal_state, :pa_name)
       .order(Arel.sql("COALESCE(report_due_date, submitted_date + interval '7' day)"))

    filter_requests

    respond_to do |format|
      format.html { render :index }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=open_dashboard.xlsx"
      end
    end
  end

  def filter_requests
    @requests = @requests.filter_by_status(params[:status]) if params[:status].present? && Request::STATUS.include?(params[:status])
    @requests = @requests.filter_by_pa(params[:pa_id]) if params[:pa_id].present?

    if params[:rfi].present? && %w[r p].include?(params[:rfi])
      case params[:rfi]
      when "p" then @requests = @requests.filter_by_internal_state("info-required").filter_by_status("Accepted")
      when "r" then @requests = @requests.filter_by_internal_state("rfi-complete").filter_by_status("Accepted")
      end
    end
  end
end
