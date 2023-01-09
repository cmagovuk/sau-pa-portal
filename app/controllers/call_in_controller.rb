class CallInController < SauLeadershipController
  def edit
    render "/errors/not_found", status: :not_found and return unless call_in.status == "Accepted"
  end

  def update
    call_in.continue_btn = params.key?(:continue)
    if params.key?(:continue) # Continue clicked - no need to check / upload document
      if call_in.update(form_params)
        redirect_to confirm_call_in_path
      else
        render :edit
      end
    else
      if call_in.update(form_params)
        if call_in.valid_document?(params[:call_in][:documents])
          call_in.add_document(params[:call_in][:documents])
          redirect_to edit_call_in_path and return
        end
      else
        call_in.valid_document?(params[:call_in][:documents])
      end
      render :edit
    end
  end

  def remove
    if params.key?(:doc_id)
      call_in.remove_document(params[:doc_id])
      redirect_to call_in_path
    else
      render step
    end
  end

  def confirm
    call_in
  end

  def submit
    @request = Request.find(params[:id])
    @request.update!(referral_type: "call", sau_call_in: Time.zone.today, call_in_type: @request.scheme_subsidy == "scheme" ? "ssi" : "soi")
    @request.audit_logs.create!(AuditLog.log(auth_user, :called_in))
    GovukNotifyService.send_called_in_email(@request)
    redirect_to sau_request_path(@request)
  end

  def call_in
    @call_in ||= Request::CallInDirection.find(params[:id])
  end

  def request_id
    params[:id]
  end

  def form_params
    params.require(:call_in).permit(call_in.permitted).transform_keys { |k| date_field_to_attribute(k) }
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
