class PostReportsController < SauLeadershipController
  def edit
    @request = Request.find(params[:id])

    @post_report = @request.post_report.presence || @request.create_post_report(status: "Draft")
    redirect_to edit_sau_request_post_report_step_path(@request, wf.first_step)
  end

private

  def wf
    @wf ||= PostReports::StepWorkflow.new(params[:sau_request_id], nil)
  end
end
