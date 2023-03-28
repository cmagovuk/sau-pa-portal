class WithdrawController < SauLeadershipController
  def edit
    @request = Request::Withdraw.find(params[:id])
    render "/errors/not_found", status: :not_found and return unless ["Accepted", "Submitted", "Pending withdrawal"].include?(@request.status)
  end

  def confirm
    @request = Request::Withdraw.find(params[:id])
    render "/errors/not_found", status: :not_found and return unless ["Accepted", "Submitted", "Pending withdrawal"].include?(@request.status)
  end

  def confirm_restore
    @request = Request::Withdraw.find(params[:id])
    render "/errors/not_found", status: :not_found and return unless ["Accepted", "Submitted", "Pending withdrawal"].include?(@request.status)
  end

  def update
    @request = Request::Withdraw.find(params[:id])
    @request.continue_btn = params.key?(:continue)
    if params.key?(:continue) # Continue clicked - no need to check / upload document
      if @request.valid?
        redirect_to confirm_withdraw_path
      else
        render :edit
      end
    elsif params.key?(:restore)
      redirect_to confirm_restore_withdraw_path
    else
      if @request.valid?
        if @request.valid_document?(params[:request][:sau_withdrawn_doc]) && @request.add_document(params[:request][:sau_withdrawn_doc])
          redirect_to withdraw_path and return
        end
      else
        @request.valid_document?(params[:request][:sau_withdrawn_doc])
      end
      render :edit
    end
  end

  def remove
    @request = Request::Withdraw.find(params[:id])
    if params.key?(:doc_id)
      @request.remove_document(params[:doc_id])
      redirect_to withdraw_path
    else
      render step
    end
  end

  def submit
    # send document to SP
    # update request status 'Withdraw pending'
    # email sau team

    @request = Request::Withdraw.find(params[:id])
    @request.update!(status: "Withdrawn")
    @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    GovukNotifyService.send_status_changed_email(@request, request_path(@request), :withdrawn)
    redirect_to sau_request_path(params[:id])
  end

  def restore
    @request = Request::Withdraw.find(params[:id])
    status = @request.internal_state.include?("Submitted") ? "Submitted" : "Accepted"
    @request.update!(withdraw_reason: nil, status: status, internal_state: @request.new_internal_state("", status))
    @request.withdraw_document.purge if @request.withdraw_document.attached?
    @request.sau_withdrawn_doc.purge if @request.sau_withdrawn_doc.attached?
    @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    # GovukNotifyService.send_status_changed_email(@request, request_path(@request), session[:decision]&.to_sym)
    redirect_to sau_request_path(params[:id])
  end
end
