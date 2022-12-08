class Request::ParTransparency < Request
  validates :par_on_td, presence: true
  validates :par_on_td, inclusion: { in: %w[y n] }
  validates :par_td_ref_no, presence: { if: ->(o) { o.par_on_td == "y" } }, length: { maximum: 20 }
  validate :validate_par_td_ref_no

  def validate_par_td_ref_no
    return if par_td_ref_no.blank? || par_on_td != "y"

    errors.add(:par_td_ref_no, I18n.t("errors.attributes.par_td_ref_no.format.#{scheme_subsidy}")) unless td_ref_regex.match(par_td_ref_no)
  end

  def td_ref_regex
    case scheme_subsidy
    # SCnnnnn
    when "scheme" then /^SC\d{5}\Z/
    # Just a numeric number, allowing upto 10 numbers
    when "subsidy" then /^\d{1,10}\Z/
    else //
    end
  end

  def permitted
    %w[par_on_td par_td_ref_no].freeze
  end
end
