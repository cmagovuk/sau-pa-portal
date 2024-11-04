class RequestTypeForm
  include ActiveModel::Model

  attr_accessor :scheme_subsidy

  OPTIONS = %w[subsidy scheme].freeze

  validates :scheme_subsidy, presence: true
  validates :scheme_subsidy, inclusion: { in: OPTIONS }

  def save(auth_user)
    if valid?
      @request = Request.create!(public_authority_id: auth_user.pa_id, user_id: auth_user.user_id, status: "Draft", scheme_subsidy:)
      @request.audit_logs.create!(AuditLog.log(auth_user, :status_change, status: @request.status))
    else
      false
    end
  end

  def request
    @request ||= Request.new
  end
end
