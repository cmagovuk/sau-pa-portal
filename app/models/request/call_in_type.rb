class Request::CallInType < Request
  SCHEME_OPTIONS = %w[ssi other].freeze
  SUBSIDY_OPTIONS = %w[soi other].freeze

  validates :call_in_type, presence: true
  validates :call_in_type, inclusion: { in: SCHEME_OPTIONS }, if: -> { scheme_subsidy == "scheme" }
  validates :call_in_type, inclusion: { in: SUBSIDY_OPTIONS }, if: -> { scheme_subsidy == "subsidy" }

  def permitted
    %w[call_in_type].freeze
  end

  def options_allowed
    if scheme_subsidy == "scheme"
      SCHEME_OPTIONS
    else
      SUBSIDY_OPTIONS
    end
  end
end
