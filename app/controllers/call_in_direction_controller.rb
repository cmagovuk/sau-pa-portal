class CallInDirectionController < ApplicationController
  def edit
    render template: "/errors/not_found", status: :not_found and return unless auth_user.can_access_request?(call_in)
    render template: "/errors/not_found", status: :not_found and return unless %w[Declined Rejected].include?(call_in.status)
  end

  def confirm
    render template: "/errors/not_found", status: :not_found and return unless auth_user.can_access_request?(call_in)
    render template: "/errors/not_found", status: :not_found and return unless %w[Declined Rejected].include?(call_in.status)
  end

  def update
    new_request = call_in.dup
    new_request.referral_type = "call"
    new_request.status = "Draft"
    new_request.call_in_type = call_in.scheme_subsidy == "scheme" ? "ssi" : "soi"
    new_request.reference_number = nil
    new_request.submitted_by_id = nil
    new_request.previous_refno = call_in.reference_number
    new_request.previous_status = call_in.status
    new_request.previous_id = call_in.id
    new_request.completed_steps = %w[referral_type]
    new_request.user_id = auth_user.user_id
    if new_request.save
      # Copy attachments

      call_in.assessment_docs.each do |d|
        new_request.assessment_docs.attach({
          io: StringIO.new(d.blob.download),
          filename: d.blob.filename,
          content_type: d.blob.content_type,
        })
      end

      call_in.character_desc_docs.each do |d|
        new_request.character_desc_docs.attach({
          io: StringIO.new(d.blob.download),
          filename: d.blob.filename,
          content_type: d.blob.content_type,
        })
      end
      call_in.audit_logs.create!(AuditLog.log(auth_user, :copy_source, reason: "Call in"))
      new_request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: new_request.status))
      new_request.audit_logs.create!(AuditLog.log(auth_user, :copied, source: call_in.reference_number))
      session[:issue_id] = new_request.id
      redirect_to edit_request_step_path("review")
    else
      redirect_to request_path
    end
  end

  def call_in
    @call_in ||= Request.find(params[:id])
  rescue StandardError
    nil
  end
end
