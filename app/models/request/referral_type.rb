class Request::ReferralType < Request
  SCHEME_OPTIONS = %w[sspi ssi call par].freeze
  SUBSIDY_OPTIONS = %w[spi soi call par].freeze

  validates :referral_type, presence: true
  validates :referral_type, inclusion: { in: SCHEME_OPTIONS }, if: -> { scheme_subsidy == "scheme" }
  validates :referral_type, inclusion: { in: SUBSIDY_OPTIONS }, if: -> { scheme_subsidy == "subsidy" }

  def permitted
    %w[referral_type].freeze
  end

  def options_allowed
    if scheme_subsidy == "scheme"
      SCHEME_OPTIONS
    else
      SUBSIDY_OPTIONS
    end
  end
end
