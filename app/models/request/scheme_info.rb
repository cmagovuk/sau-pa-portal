class Request::SchemeInfo < Request
  validates :budget, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :max_amt, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :scheme_name, length: { maximum: 255 }

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

  def permitted
    %w[scheme_name budget tax_amt max_amt].freeze
  end
end
