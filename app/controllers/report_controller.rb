class ReportController < SauLeadershipController
  def edit
    @request = Request::UploadReport.find(params[:id])
  end

  def report_upload
    @request = Request::UploadReport.find(params[:id])
    if params.key?(:request) && params[:request].key?(:final_report)
      if @request.valid_document?(params[:request][:final_report])
        @request.add_document(params[:request][:final_report])
        redirect_to "/sau_requests/#{@request.id}/report" and return
      else
        render :edit
      end
    elsif @request.valid?
      redirect_to "/sau_requests/#{@request.id}/report_confirm" and return
    else
      render :edit
    end
  end

  def remove
    @request = Request::UploadReport.find(params[:id])
    if params.key?(:doc_id)
      @request.remove_document(params[:doc_id])
      #  redirect_to "/sau_requests/#{@request.id}/report"
      redirect_to "#{sau_request_path(@request)}/report"
    else
      render step
    end
  end

  def request_id
    params[:id]
  end

  def report_confirm
    @request = Request::UploadReport.find(params[:id])
  end

  def report_confirm_submit
    @request = Request::UploadReport.find(params[:id])
    @request.update!(status: "Completed", completed_date: Time.zone.now)
    @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    GovukNotifyService.send_status_changed_email(@request, request_path(@request), :completed)
    redirect_to sau_request_path(@request)
  end
end
