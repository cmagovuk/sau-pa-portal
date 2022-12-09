class RequestStepsController < ApplicationController
  before_action :load_record
  before_action :redirect_completed

  def edit
    if wf.step_valid?
      render step
    else
      render "/errors/not_found", status: :not_found
    end
  end

  def upload
    step_model.continue_btn = params.key?(:continue)
    if params.key?(:continue) # Continue clicked - no need to check / upload document
      if step_model.update(form_params)
        wf.update_completed_steps
        redirect_to edit_request_step_path(next_step)
      else
        render step
      end
    else
      if step_model.update(form_params)
        if step_model.valid_document?(params[:request][:documents])
          step_model.add_document(params[:request][:documents])
          wf.update_completed_steps
          redirect_to edit_request_step_path(step) and return
        end
      else
        step_model.valid_document?(params[:request][:documents])
      end
      render step
    end
  end

  def remove
    if params.key?(:doc_id)
      step_model.remove_document(params[:doc_id])
      redirect_to edit_request_step_path(step)
    else
      render step
    end
  end

  def update
    if step_model.info_only? || step_model.update(form_params)
      wf.update_completed_steps
      if next_step
        redirect_to request_step_path(next_step)
      elsif wf.completed_steps?
        step_model.update!(reference_number: Request.next_reference_number) if step_model.reference_number.blank?
        step_model.submission_text.attach(({
          io: StringIO.new(render_to_string("requests/submission", formats: [:pdf])),
          filename: "submission.pdf",
          content_type: "application.pdf",
        }))
        result = request_service.submit_request(@request)
        if result
          step_model.update!(status: "Submitted", submitted_by_id: auth_user.user_id)
          step_model.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: step_model.status))
          GovukNotifyService.send_submit_request_email(step_model, auth_user) if step_model.reference_number.present?
          redirect_to request_submitted_path
        else
          Rails.logger.warn "Failed to submit request"
          render "/errors/internal_server_error", status: :internal_server_error
        end
      else
        redirect_to edit_request_step_path(wf.missed_step)
      end
    else
      Rails.logger.warn "Failed to save request step"
      render step
    end
  end

  helper_method :previous_step_path, :step, :step_path

private

  def previous_step_path
    return step_path(wf.previous_step) if wf.previous_step

    root_path
  end

  def step_path(current_step)
    edit_request_step_path(current_step)
  end

  def load_record
    @request = step_model
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def form_params
    params.require(:request).permit(@request.permitted).transform_keys { |k| date_field_to_attribute(k) }
  end

  def date_field_to_attribute(key)
    case key
    when /\(3i\)\Z/ then "#{key[0...-4]}_day"
    when /\(2i\)\Z/ then "#{key[0...-4]}_month"
    when /\(1i\)\Z/ then "#{key[0...-4]}_year"
    else key
    end
  end

  def request_service
    @request_service ||= RequestService.new
  end

  def redirect_completed
    redirect_to request_submitted_path unless step_model.status == "Draft"
  end

  delegate :step, :step_model, :next_step, to: :wf

  def wf
    @wf ||= Requests::StepWorkflow.new(request)
  end
end
