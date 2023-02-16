class SauRequestsController < SauTeamController
  def show
    @request = Request.find(params[:id])
  end

  def view
    @request = Request.find(params[:id])
  end

  def due_date
    @request = Request::ReportDueDate.find(params[:id])
  end

  def set_due_date
    @request = Request::ReportDueDate.find(params[:id])
    if @request.update(form_params)
      # TBD Audit
      @request.audit_logs.create!(AuditLog.log(auth_user, :report_due_date, date: @request.report_due_date.strftime("%d %B %Y")))

      redirect_to sau_request_path
    else
      render :due_date
    end
  end

  def request_id
    params[:id]
  end

private

  def form_params
    params.require(:request).permit(%w[report_due_date]).transform_keys { |k| date_field_to_attribute(k) }
  end

  def date_field_to_attribute(key)
    case key
    when /\(3i\)\Z/ then "#{key[0...-4]}_day"
    when /\(2i\)\Z/ then "#{key[0...-4]}_month"
    when /\(1i\)\Z/ then "#{key[0...-4]}_year"
    else key
    end
  end
end
