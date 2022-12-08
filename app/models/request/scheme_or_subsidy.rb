class Request::SchemeOrSubsidy < Request
  OPTIONS = %w[subsidy scheme].freeze

  validates :scheme_subsidy, presence: true
  validates :scheme_subsidy, inclusion: { in: OPTIONS }

  def permitted
    %w[scheme_subsidy].freeze
  end
end
