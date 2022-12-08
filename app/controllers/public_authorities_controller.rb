class PublicAuthoritiesController < AdminController
  def index
    @authorities = PublicAuthority.order(:pa_name)
  end

  def show
    @authority = PublicAuthority.find(params[:id])
  end

  def new
    @authority = PublicAuthority.new
  end

  def create
    @authority = PublicAuthority.new(public_authority_params)

    if @authority.save
      @authority.audit_logs.create!(AuditLog.log(auth_user, :created_pa, pa: @authority.pa_name))
      redirect_to @authority
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @authority = PublicAuthority.find(params[:id])
  end

  def update
    @authority = PublicAuthority.find(params[:id])

    if @authority.update(public_authority_params)
      redirect_to @authority
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def public_authority_params
    params.require(:authority).permit(:pa_name)
  end
end
