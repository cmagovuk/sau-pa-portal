class InformationResponsesController < ApplicationController
  def edit
    information_request
  end

  def update
    if params[:information_request].present? && params[:information_request].key?(:documents)
      if information_request.valid_document?(params[:information_request][:documents])
        information_request.add_response_doc(params[:information_request][:documents])
        information_request.update!(status: "response-unconfirmed")
        redirect_to edit_information_response_path and return
      end
    elsif information_request.response_doc.attached?
      redirect_to confirm_information_response_path and return
    else
      information_request.errors.add(:documents, I18n.t("errors.upload.no_file_error_message"))
    end
    render :edit
  end

  def confirm
    information_request
  end

  def submit
    if information_request.valid?
      if request_service.submit_response(information_request)
        information_request.update!(status: "response-confirmed")
        information_request.request.audit_logs.create!(AuditLog.log(auth_user, :info_response))
        information_request.request.update!(internal_state: "rfi-complete")
        GovukNotifyService.send_rfi_response_email(information_request.request, request_service.sau_email) if request_service.sau_email.present?
      end
      redirect_to summary_information_response_path
    else
      render :response_confirm and return
    end
  end

  def remove
    information_request.remove_response_doc
    information_request.update!(status: "request-confirmed")
    redirect_to edit_information_response_path
  end

  def summary
    information_request
  end

  def information_request
    @information_request ||= InformationRequest.find(params[:id])
  end

private

  def information_request_params
    params.require(:information_request).permit(:request_id, :request_doc, :response_doc, :status)
  end

  def request_service
    @request_service ||= RequestService.new
  end
end
