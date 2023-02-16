class WithdrawController < SauLeadershipController
  def edit
    @request = Request.find(params[:id])
    render "/errors/not_found", status: :not_found and return unless @request.status == "Accepted"
    # @withdraw_form = WithdrawForm.new(param: params[:id])
    # @withdraw_form.decision = session[:decision]
    # render "/errors/not_found", status: :not_found and return unless @withdraw_form.status == "Accepted"
  end

  def update
    @request = Request.find(params[:id])
    # GovukNotifyService.send_status_changed_email(@request, request_path(@request), session[:decision]&.to_sym)
    @request.update!(status: "Withdrawn")
    @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    redirect_to sau_request_path(params[:id])
  end
end
