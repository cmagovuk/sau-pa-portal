class PublicAuthoritiesController < AdminController
  def index
    @authorities = PublicAuthority.order(:pa_name)
  end

  def show
    @authority = PublicAuthority.find(params[:id])
    @users = if params[:show_all] == "x"
               @authority.users.order(disabled: :desc, user_name: :asc)
             else
               @authority.users.active_users.order(:user_name)
             end
  end

  def new
    load_org_levels

    @authority = PublicAuthority.new
  end

  def create
    @authority = PublicAuthority.new(public_authority_params)

    if @authority.save
      @authority.audit_logs.create!(AuditLog.log(auth_user, :created_pa, pa: @authority.pa_name))
      redirect_to @authority
    else
      load_org_levels
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_org_levels

    @authority = PublicAuthority.find(params[:id])
  end

  def update
    @authority = PublicAuthority.find(params[:id])

    if @authority.update(public_authority_params)
      redirect_to @authority
    else
      load_org_levels
      render :edit, status: :unprocessable_entity
    end
  end

  def assign_sub
    @authority = PublicAuthority.find(params[:id])
    @authorities ||= PublicAuthority.no_umbrella.order(:pa_name)
      .reject { |a| a.id == params[:id] }
      .map { |a| [a.pa_name, a.id] }
    @assign_sub = AssignSubForm.new
  end

  def add_sub
    @authority = PublicAuthority.find(params[:id])
    @authorities ||= PublicAuthority.no_umbrella.order(:pa_name)
      .reject { |a| a.id == params[:id] }
      .map { |a| [a.pa_name, a.id] }
    @assign_sub = AssignSubForm.new(params.require(:assign_sub).permit(:sub_authority))

    if @assign_sub.valid?
      @sub_authority = PublicAuthority.find(@assign_sub.sub_authority)
      @sub_authority.update!(umbrella_authority_id: @authority.id)
      redirect_to assign_sub_public_authority_path(@authority)
    else
      render :assign_sub
    end
  end

  def remove_sub
    @sub_authority = PublicAuthority.find(params[:pa_id])
    if @sub_authority.umbrella_authority_id == params[:id]
      @sub_authority.update!(umbrella_authority_id: nil)
    end
    redirect_to assign_sub_public_authority_path
  end

  def has_users?
    @has_users || @authority.users.where(role: %w[su u]).count.positive?
  end

  def has_requests?
    @has_requests || Request.pa_requests(@authority.id).count.positive?
  end

  def is_sub_authority?
    @authority.umbrella_authority_id.present?
  end

  helper_method :has_users?, :has_requests?, :is_sub_authority?

private

  def public_authority_params
    params.require(:authority).permit(%w[pa_name org_level_1 org_level_2 org_level_1_select org_level_2_select])
  end

  def load_org_levels
    @level_1_orgs = PublicAuthority.select(:org_level_1).distinct.where.not(org_level_1: [nil, ""]).map { |a| [a.org_level_1, a.org_level_1] }

    @level_2_orgs = PublicAuthority.select(%i[org_level_1 org_level_2]).distinct.where.not(org_level_2: [nil, ""])
    @grouped_level_2_orgs = Hash.new([])
    @level_2_orgs.each { |o| @grouped_level_2_orgs[o.org_level_1] += [o.org_level_2] }
  end
end
