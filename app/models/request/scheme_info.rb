class Request::SchemeInfo < Request
  validates :budget, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :tax_low, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :tax_high, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :max_amt, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :scheme_name, length: { maximum: 255 }
  validate :validate_tax_range

  with_options unless: -> { referral_type == "par" && par_on_td == "y" } do
    validates :scheme_name, presence: true
    validate :budget_or_tax_amt_present
  end

  delegate :pa_name, to: :public_authority

  def budget_or_tax_amt_present
    if budget.blank? && tax_amt.blank?
      errors.add(:budget, I18n.t("errors.scheme_info.blank_budget_and_tax"))
    end
  end

  def validate_tax_range
    return unless tax_amt == "over_30000"
    return if tax_low.blank? || tax_high.blank?

    errors.add(:tax_low, "Select a range from the dropdown above when less than £30,000,001") unless tax_low > 30_000_000
    errors.add(:tax_low, "Enter a valid low range value") unless tax_low % 10_000_000 == 1
    errors.add(:tax_high, "Enter a valid high range value") unless (tax_high % 10_000_000).zero?
    errors.add(:tax_high, "Low and high values to not match a valid range") if tax_low % 10_000_000 == 1 && tax_high != tax_low + 9_999_999
  end

  def permitted
    %w[scheme_name budget tax_amt max_amt tax_low tax_high].freeze
  end
end
