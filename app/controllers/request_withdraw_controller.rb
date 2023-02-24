class RequestWithdrawController < SuperUserController
  def edit
    @request = Request::RequestWithdraw.find(params[:id])
  end

  def confirm
    @request = Request::RequestWithdraw.find(params[:id])
  end

  def update
    @request = Request::RequestWithdraw.find(params[:id])
    @request.continue_btn = params.key?(:continue)
    if params.key?(:continue) # Continue clicked - no need to check / upload document
      if @request.update(form_params)
        redirect_to confirm_request_withdraw_path
      else
        render :edit
      end
    else
      if @request.update(form_params)
        if @request.valid_document?(params[:request][:withdraw_document]) && @request.add_document(params[:request][:withdraw_document])
          redirect_to request_withdraw_path and return
        end
      else
        @request.valid_document?(params[:request][:withdraw_document])
      end
      render :edit
    end
  end

  def remove
    @request = Request::RequestWithdraw.find(params[:id])
    if params.key?(:doc_id)
      @request.remove_document(params[:doc_id])
      redirect_to request_withdraw_path
    else
      render step
    end
  end

  def submit
    @request = Request::RequestWithdraw.find(params[:id])
    # send document to SP
    # update request status 'Withdraw pending'
    # email sau team
    if request_service.request_withdraw(@request)
      @request.update!(status: "Pending withdrawal", internal_state: @request.new_internal_state(@request.status))
      @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
      GovukNotifyService.send_request_withdraw_email(@request, request_service.sau_email) if request_service.sau_email.present?
    end
    redirect_to summary_request_withdraw_path
  end

  def summary
    @request = Request::RequestWithdraw.find(params[:id])
  end

  def form_params
    params.require(:request).permit(%w[withdraw_reason])
  end

  def request_id
    params[:id]
  end

  def report_confirm
    @request = Request::RequestWithdraw.find(params[:id])
  end

  def report_confirm_submit
    @request = Request::RequestWithdraw.find(params[:id])
    @request.update!(status: "Completed")
    @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    GovukNotifyService.send_status_changed_email(@request, request_path(@request), :completed)
    redirect_to sau_request_path(@request)
  end

private

  def request_service
    @request_service ||= RequestService.new
  end
end
