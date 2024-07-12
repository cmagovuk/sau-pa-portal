class ReportPaNamesController < AdminController
  def index
    @report_pa_names = if params[:show_all] == "x"
                         ReportPaName.order(disabled: :desc, pa_name: :asc)
                       else
                         ReportPaName.active_names.order(:pa_name)
                       end
  end

  def new
    @report_pa_name = ReportPaName.new
  end

  def create
    @report_pa_name = ReportPaName.new(report_pa_name_params)

    if @report_pa_name.save
      redirect_to report_pa_names_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @report_pa_name = ReportPaName.find(params[:id])
  end

  def update
    @report_pa_name = ReportPaName.find(params[:id])

    if @report_pa_name.update(report_pa_name_params)
      redirect_to report_pa_names_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def change_state
    @report_pa_name = ReportPaName.find(params[:id])
    @report_pa_name.update!(disabled: @report_pa_name.disabled == "x" ? nil : "x")
    redirect_to report_pa_names_path
  end

private

  def report_pa_name_params
    params.require(:report_pa_name).permit(%w[pa_name org_level_1 org_level_2 org_level_1_select org_level_2_select])
  end
end
