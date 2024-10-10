class InformationRequestsController < SauLeadershipController
  def new
    @information_request = Request.find(params[:id]).information_requests.new
  end

  def create
    @information_request = Request.find(params[:id]).information_requests.new

    if params[:information_request].present? &&
        params[:information_request].key?(:documents) &&
        params[:information_request][:documents].compact_blank.count.positive?
      if @information_request.valid_request_documents?(params[:information_request][:documents])
        @information_request.add_request_doc(params[:information_request][:documents])
        @information_request.update!(status: "request-unconfirmed")
        redirect_to edit_information_request_path(@information_request) and return
      end
    else
      @information_request.errors.add(:documents, I18n.t("errors.upload.no_file_error_message"))
    end
    render :new
  end

  def confirm
    information_request
  end

  def edit
    information_request
  end

  def amend
    information_request
  end

  def amend_remove
    information_request
    if params.key?(:doc_id)
      @information_request.remove_request_doc(params[:doc_id])
      @information_request.request.audit_logs.create!(AuditLog.log(auth_user, :amend_remove, doc_set: "RFI"))
      redirect_to amend_information_request_path(@information_request)
    else
      render :amend
    end
  end

  def amend_update
    information_request
    if params[:information_request].present? && params[:information_request].key?(:request_doc)
      if @information_request.valid_request_documents?(params[:information_request][:request_doc])
        @information_request.add_request_doc(params[:information_request][:request_doc])
        @information_request.request.audit_logs.create!(AuditLog.log(auth_user, :amend_added, doc_set: "RFI"))
        redirect_to amend_information_request_path(@information_request)
      else
        render :amend
      end
    else
      render :amend
    end
  end

  def remove
    information_request
    if params.key?(:doc_id)
      if @information_request.request_doc.count == 1
        information_request.destroy!
        redirect_to new_information_request_path(information_request.request)
      else
        @information_request.remove_request_doc(params[:doc_id])
        redirect_to edit_information_request_path(@information_request)
      end
    else
      render :edit
    end
  end

  def update
    information_request
    if params[:information_request].present? &&
        params[:information_request].key?(:request_doc) &&
        params[:information_request][:request_doc].compact_blank.count.positive?
      if @information_request.valid_request_documents?(params[:information_request][:request_doc])
        @information_request.add_request_doc(params[:information_request][:request_doc])
        redirect_to edit_information_request_path(@information_request)
      else
        render :edit
      end
    elsif @information_request.valid?
      redirect_to confirm_information_request_path(information_request) and return
    else
      render :edit
    end
  end

  def submit
    if information_request.update(status: "request-confirmed")
      information_request.request.update!(internal_state: information_request.request.new_internal_state("info-required", "rfi-complete"))
      information_request.request.audit_logs.create!(AuditLog.log(auth_user, :info_request))
      pa_su_users = information_request.request.public_authority.users.active_users.super_users.select(:email).map(&:email)
      notify_users = pa_su_users.union([information_request.request.submitted_by.email]) if information_request.request.submitted_by.disabled.blank?
      notify_users.map do |email|
        # send notification to client
        GovukNotifyService.send_rfi_request_email(email, information_request.request, request_path(information_request.request))
      end
      redirect_to sau_request_path(information_request.request)
    else
      render :confirm and return
    end
  end

  def information_request
    @information_request ||= InformationRequest.find(params[:id])
  end

  def request_id
    if action_name == "new" || action_name == "create"
      params[:id]
    else
      information_request.request.id
    end
  end

private

  def information_request_params
    params.require(:information_request).permit(:request_id, :request_doc, :response_doc, :status)
  end
end
