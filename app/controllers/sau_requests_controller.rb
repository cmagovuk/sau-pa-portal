class SauRequestsController < SauTeamController
  def show
    @request = Request.find(params[:id])
  end

  def view
    @request = Request.find(params[:id])
  end

  def request_id
    params[:id]
  end
end
