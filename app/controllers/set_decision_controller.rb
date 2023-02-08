class SetDecisionController < SauLeadershipController
  def edit
    @set_decision_form = SetDecisionForm.new(param: params[:id])
    @set_decision_form.decision = session[:decision]
  end

  def update
    @set_decision_form = SetDecisionForm.new(set_decision_params.merge(param: params[:id]))
    @set_decision_form.continue_btn = params.key?(:continue)
    if params.key?(:continue) # Continue clicked - no need to check / upload document
      if @set_decision_form.valid?
        session[:decision] = @set_decision_form.decision
        redirect_to confirm_set_decision_path
      else
        render :edit
      end
    else
      if @set_decision_form.valid?
        if @set_decision_form.valid_document?(params[:set_decision][:documents]) && @set_decision_form.add_document(params[:set_decision][:documents])
          session[:decision] = @set_decision_form.decision
          redirect_to edit_set_decision_path and return
        end
      else
        @set_decision_form.valid_document?(params[:set_decision][:documents])
      end
      render :edit
    end
  end

  def remove
    if params.key?(:doc_id)
      @set_decision_form = SetDecisionForm.new(param: params[:id])
      @set_decision_form.remove_document(params[:doc_id])
      redirect_to edit_set_decision_path and return
    else
      render :edit
    end
  end

  def confirm
    @set_decision_form = SetDecisionForm.new(param: params[:id])
    @set_decision_form.decision = session[:decision]
  end

  def submit
    if session[:decision].present?
      @request = Request.find(params[:id])
      # send notification to client
      GovukNotifyService.send_status_changed_email(@request, request_path(@request), session[:decision]&.to_sym)
      @request.update!(status: t(session[:decision]&.to_sym, scope: "helpers.label.set_decision.decision_options"))
      @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
      session[:decision] = nil
      redirect_to sau_request_path(params[:id])
    else
      render :edit
    end
  end

  def request_id
    params[:id]
  end

private

  def set_decision_params
    params.require(:set_decision).permit(:decision)
  end
end
